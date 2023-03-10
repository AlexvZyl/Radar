using Zygote: @ignore
using Base: AbstractVecOrTuple, batch_size_err_str
using Flux: convfilter, create_bias
using Flux
using CUDA
using Zygote
using ChainRulesCore
using Reduce

@enum LayerType begin 
    StdConv
    TemporalConv
    Meanpool
    Maxpool
end

Base.@kwdef mutable struct Layer
    stride = (0,0,0)
    kernel = (0,0,0)
    input_size = (0,0,0)
    output_size = (0,0,0)
    padding = (0,0,0)
    kernel_count = 0
    temporal_stride_frames = 0
    temporal_kernel_frames = 0
    temporal_frame_size = 0
    temporal_frame_count = 0
    temporal_frames_count_out = 0
    type = TemporalConv
    dilation = 1
    channels = 1
end

function Base.display(layer::Layer)
    display("------------------------------------------------------------")
    display("Type: $(layer.type)") 
    display("Input Size: $(layer.input_size)") 
    display("Output Size: $(layer.output_size)") 
    display("Kernel: $(layer.kernel)") 
    display("Stride: $(layer.stride)") 
    display("Padding: $(layer.padding)") 
    display("Kernel Count: $(layer.kernel_count)") 
    display("Temporal Kernel Frames: $(layer.temporal_kernel_frames)") 
    display("Temporal Stride Frames: $(layer.temporal_stride_frames)") 
    display("Temporal Frame Size: $(layer.temporal_frame_size)") 
    display("Temporal Frame Count: $(layer.temporal_frame_count)") 
    display("------------------------------------------------------------")
end

function should_pad(layer::Layer)
    pad = false
    for i = 1:length(layer.input_size)
        if (layer.kernel[i] * layer.dilation) > (layer.input_size[i] + layer.padding[i])
            pad = true
            break
        end
    end 
    return pad
end

function padding(layer::Layer)
    if should_pad(layer)
        layer.padding = (
            max(0, (layer.kernel[1] * layer.dilation[1]) - layer.input_size[1]),
            max(0, (layer.kernel[2] * layer.dilation[2]) - layer.input_size[2]),
            max(0, (layer.kernel[3] * layer.dilation[3]) - layer.input_size[3])
        )
    end
    output_size(layer)
    return layer.padding
end

function is_conv(layer::Layer)
    return layer.type == StdConv || layer.type == TemporalConv
end

function is_pool(layer::Layer)
    return !is_conv(layer)
end

function kernel(layer::Layer)
    if is_pool(layer) return layer.kernel end
    k_z = ceil(Int, layer.temporal_kernel_frames * layer.temporal_frame_size)
    k_z = k_z > layer.input_size[3] ? layer.input_size[3] : k_z
    layer.kernel = ( layer.kernel[1], layer.kernel[2], k_z )
    return layer.kernel
end

function stride(layer::Layer)
    if is_pool(layer) return layer.stride end
    layer.stride = (
        layer.stride[1],
        layer.stride[2],
        ceil(Int, layer.temporal_frame_size * layer.temporal_stride_frames)
    )
    return layer.stride
end

function output_size(layer::Layer)
    layer.output_size = (
        floor(Int, (layer.input_size[1] + 2*layer.padding[1] - layer.kernel[1])/layer.stride[1])+1,
        floor(Int, (layer.input_size[2] + 2*layer.padding[2] - layer.kernel[2])/layer.stride[2])+1,
        layer.kernel_count*(floor(Int, (layer.input_size[3] + 2*layer.padding[3] - layer.kernel[3])/layer.stride[3])+1),
    )
    return layer.output_size
end

function temporal_frames_count_out(layer::Layer)
    if is_conv(layer)
        layer.temporal_frames_count_out = floor(Int, (layer.input_size[3] - layer.kernel[3]) / layer.stride[3]) + 1
    elseif is_pool(layer)
        layer.temporal_frames_count_out = layer.temporal_frame_count
    end
    return layer.temporal_frames_count_out
end

function temporal_frame_size_out(layer::Layer)
    if is_conv(layer)
        return layer.kernel_count
    elseif is_pool(layer)
        return layer.temporal_frame_size * (layer.output_size[3] / layer.input_size[3]) 
    end
end

function setup(layer::Layer)
    kernel(layer)
    stride(layer)
    padding(layer)
    output_size(layer)
end

function init(existing::Layer, type::LayerType)
    new = Layer()
    new.type = type
    new.input_size = output_size(existing)
    new.temporal_frame_size = temporal_frame_size_out(existing)
    new.temporal_frame_count = temporal_frames_count_out(existing)
    return new
end

function flux(layer::Layer; act_func = relu)
    if layer.type == TemporalConv
        return TempConv(layer, act_func)
    elseif layer.type == StdConv
        return Conv(layer.kernel, layer.channels => layer.channels, act_func, stride = layer.stride, pad = layer.padding, dilation = layer.dilation)
    elseif layer.type == Meanpool
        return MeanPool(layer.kernel, stride = layer.stride, pad = layer.padding)
    elseif layer.type == Maxpool
        return MaxPool(layer.kernel, stride = layer.stride, pad = layer.padding)
    end
end

# Temporal Convolutional Layer.

mutable struct TempConv{L,F,W,B}
    layer::L
    σ::F
    weights::W
    bias::B
end

# Trainable parameters.
Flux.params(t::TempConv) = Flux.params([Flux.params(t.weights), Flux.params(t.bias)])
Flux.trainable(t::TempConv) = (w=t.weights, b=t.bias)
Flux.@functor TempConv

function TempConv(L::Layer, F::Function)
    W = [ convfilter(L.kernel, L.channels => L.channels) ]
    for _ in 1:L.kernel_count-1
        push!(W, convfilter(L.kernel, L.channels => L.channels))
    end
    B = create_bias(W[1], true, size(W, 4))
    return TempConv(L, F, W, B)
end

function conv_large(input::AbstractArray{T}, m::TempConv) where T <: AbstractFloat
    map(w -> NNlib.conv(input, w, stride=m.layer.stride), m.weights)
end

function cat_temporal(input, m::TempConv, t::Int)
    out = cat([ input[k][:,:,t,:,:] for k in 1:length(m.weights) ]..., dims=3) 
    new_size = size(out)
    return reshape(out, new_size[1], new_size[2], new_size[3], m.layer.channels, new_size[4])
end

function cat_kernels(input, m::TempConv)
   return cat([ cat_temporal(input, m, t) for t in 1:size(input[1])[3] ]..., dims=3)
end

function format(input, m::TempConv)
    return cat_kernels(input, m)
end

# I think this was just compilation?... Lol.
# Doing small convolutions: 1.84GB + 296.89MB = 2.14GB
# Doing larger convolutions: 108MB + 1.342GB  = 1.45GB

function (m::TempConv)(input::AbstractArray{T}) where T <: AbstractFloat

    # Convolution.
    # result = @time conv_non_mut(input,m)
    result = conv_large(input,m)

    # Efficient format.
    result = format(result,m)

    # Activation.
    σ = NNlib.fast_act(m.σ, result)
    return σ.(result.+ Flux.conv_reshape_bias(m.bias, m.layer.stride))

end

# Generate LeNet5 with temporal convolution.

function gen_lenet_layers(inputsize)

    # Conv 1.
    c1 = Layer()
    c1.type = TemporalConv
    c1.input_size = inputsize
    c1.kernel_count = 6
    c1.kernel = (9,9)
    c1.stride = (3,3)
    c1.temporal_kernel_frames = 2
    c1.temporal_stride_frames = 1
    c1.temporal_frame_size = 2
    c1.temporal_frame_count = inputsize[3] / c1.temporal_frame_size
    setup(c1)
     
    # Pool 1.
    a1 = init(c1, Meanpool)
    a1.kernel_count = 1
    a1.kernel = (2,2,1)
    a1.stride = (2,2,1)
    setup(a1)

    # Conv 2.
    c2 = init(a1, TemporalConv)
    c2.kernel = (2,2) 
    c2.stride = (1,1) 
    c2.kernel_count = 16
    c2.temporal_stride_frames = 1
    c2.temporal_kernel_frames = 1
    setup(c2) 

    # Pool 2.
    a2 = init(c2, Meanpool)
    a2.kernel_count = 1
    a2.kernel = (2,2,1)
    a2.stride = (2,2,1)
    setup(a2)

    # Conv 3.
    c3 = init(a2, TemporalConv)
    c3.kernel = c3.input_size
    c3.stride = (1,1) 
    c3.kernel_count = 120
    c3.temporal_stride_frames = 1
    c3.temporal_kernel_frames = 2
    setup(c3) 

    return Dict([
        ("c1", c1),
        ("a1", a1),
        ("c2", c2),
        ("a2", a2),
        ("c3", c3)
    ])
end
