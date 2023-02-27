using Flux

@enum LayerType begin 
    TemporalConv
    Meanpool
    Maxpool
end

Base.@kwdef mutable struct Layer
    stride = (0,0,0)
    kernel = (0,0,0)
    input_size = (0,0,0)
    kernel_count = 0
    temporal_stride_frames = 0
    temporal_kernel_frames = 0
    temporal_frame_size = 0
    temporal_frame_count = 0
    type = TemporalConv
end

function kernel(layer::Layer)
    if layer.type != TemporalConv return layer.kernel end
    layer.kernel = (
        layer.kernel[1],
        layer.kernel[2],
        ceil(Int, layer.temporal_kernel_frames * layer.temporal_frame_size)
    )
    return layer.kernel
end

function stride(layer::Layer)
    if layer.type != TemporalConv return layer.stride end
    layer.stride = (
        layer.stride[1],
        layer.stride[2],
        ceil(Int, layer.temporal_frame_size * layer.temporal_stride_frames)
    )
    return layer.stride
end

function output_size(layer::Layer)
    kernel(layer)
    stride(layer)
    return  (
        floor(Int, (layer.input_size[1] - layer.kernel[1])/layer.stride[1])+1,
        floor(Int, (layer.input_size[2] - layer.kernel[2])/layer.stride[2])+1,
        layer.kernel_count*(floor(Int, (layer.input_size[3] - layer.kernel[3])/layer.stride[3])+1),
    )
end

function temporal_frames_count_out(layer::Layer)
    if layer.type == TemporalConv
        return floor(Int, (layer.input_size[3] - kernel(layer)[3]) / stride(layer)[3]) + 1
    elseif layer.type == Maxpool || layer.type == Meanpool
        return layer.temporal_frame_count
    end
end

function temporal_frame_size_out(layer::Layer)
    if layer.type == TemporalConv
        return layer.kernel_count
    elseif layer.type == Maxpool || layer.type == Meanpool
        return layer.temporal_frame_size * (output_size(layer)[3] / layer.input_size[3]) 
    end
end

function setup(layer::Layer)
    kernel(layer)
    stride(layer)
    output_size(layer)
end

function init(layer::Layer, type::LayerType)
    new = Layer()
    new.type = type
    new.input_size = output_size(layer)
    new.temporal_frame_size = temporal_frame_size_out(layer)
    new.temporal_frame_count = temporal_frames_count_out(layer)
    return new
end

function flux(layer::Layer; act_func = relu)
    if layer.type == TemporalConv
        return Conv(layer, act_func)
    elseif layer.type == Meanpool
        return MeanPool(layer.kernel, stride = layer.stride)
    elseif layer.type == Maxpool
        return MaxPool(layer.kernel, stride = layer.stride)
        
    end
end

function gen_lenet_layers(inputsize)

    # Conv 1.
    c1 = Layer()
    c1.type = TemporalConv
    c1.input_size = inputsize
    c1.kernel_count = 6
    c1.kernel = (11,11)
    c1.stride = (4,4)
    c1.temporal_kernel_frames = 1
    c1.temporal_stride_frames = 1
    c1.temporal_frame_size = 2
    c1.temporal_frame_count = inputsize[3] / c1.temporal_frame_size
    setup(c1)
     
    # Pool 1.
    a1 = init(c1, Meanpool)
    a1.kernel_count = 1
    a1.kernel = (3,3,3)
    a1.stride = (3,3,3)
    setup(a1)

    # Conv 2.
    c2 = init(a1, TemporalConv)
    c2.kernel = (5,5) 
    c2.stride = (1,1) 
    c2.kernel_count = 16
    c2.temporal_stride_frames = 1
    c2.temporal_kernel_frames = 1
    setup(c2) 

    # Pool 2.
    a2 = init(c2, Meanpool)
    a2.kernel_count = 1
    a2.kernel = (3,3,3)
    a2.stride = (3,3,3)
    setup(a2)

    # Conv 3.
    c3 = init(a2, TemporalConv)
    c3.kernel = c3.input_size
    c3.stride = (1,1) 
    c3.kernel_count = 120
    c3.temporal_stride_frames = 1
    c3.temporal_kernel_frames = 1
    setup(c3) 

    return Dict([
        ("c1", c1),
        ("a1", a1),
        ("c2", c2),
        ("a2", a2),
        ("c3", c3)
    ])
end


struct TempConv{L::Layer, A}
    layer
    activ_func
end

function (m::TempConv)(x)
    # Extract input size
    Ix, Iy, Iz = size(input)
    # Extract kernel size
    Kx, Ky, Kz = size(kernel)
    # Calculate output size
    Ox = (Ix - Kx + 2*pad) ÷ stride[1] + 1
    Oy = (Iy - Ky + 2*pad) ÷ stride[2] + 1
    Oz = Iz
    # Pad input if necessary
    if pad > 0
        input = Flux.pad(input, ((pad, pad), (pad, pad), (0, 0)), :constant)
    end
    # Create empty output tensor
    output = zeros(Float32, Ox, Oy, Oz, size(kernel, 4))
    # Loop over z direction
    for i = 1:Oz
        # Extract input slice
        slice = input[:, :, i:i+Kz-1, :]
        # Loop over C kernels
        for j = 1:size(kernel, 4)
            # Extract kernel
            k = kernel[:, :, :, j]
            # Perform 2D convolution
            conv = Conv(slice[:, :, :, j], k, stride=stride[1:2], pad=pad, dilation=dilation)
            # Store 2D convolution result
            output[:, :, i, j] = conv
        end
    end
    return output
end

Flux.@functor TempConv
