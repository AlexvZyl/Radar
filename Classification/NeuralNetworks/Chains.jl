using MLUtils
using Flux

# Chain types.
@enum ChainType begin 
    LeNet5
    LeNet5Adapted
    AlexNet
    VGG16
end

# Get the type as a string.
function get_type_string(type::ChainType)
    if type == LeNet5
        return "LeNet5"
    elseif type == LeNet5Adapted
        return "LeNet5Adapted"
    elseif type == AlexNet
        return "AlexNet"
    elseif type == VGG16
        return "VGG-16"
    else 
        @assert false "Invalid chain type."
    end
end

# Create the network given the type.
function create_network(chain_type::ChainType, image_size, n_classes)
    model = nothing
    if chain_type == LeNet5
        model = create_LeNet5(image_size, n_classes)
    elseif chain_type == LeNet5Adapted
        model = create_LeNet5_Adapted(image_size, n_classes, kt = 2, st = 1)
    elseif chain_type == AlexNet
        model = create_AlexNet(image_size, n_classes)
    elseif chain_type == VGG16
        model = create_VGG16(image_size, n_classes)
    else
        @assert false "Invalid model type."
    end
    return model
end

# VGG-16
function create_VGG16(imgsize, nclasses)
    return Chain(
        Conv((3, 3), imgsize[end] => 64, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(64),
        Conv((3, 3), 64 => 64, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(64),
        MaxPool((2,2)),
        Conv((3, 3), 64 => 128, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(128),
        Conv((3, 3), 128 => 128, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(128),
        MaxPool((2,2)),
        Conv((3, 3), 128 => 256, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(256),
        Conv((3, 3), 256 => 256, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(256),
        Conv((3, 3), 256 => 256, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(256),
        MaxPool((2,2)),
        Conv((3, 3), 256 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        Conv((3, 3), 512 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        Conv((3, 3), 512 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        MaxPool((2,2)),
        Conv((3, 3), 512 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        Conv((3, 3), 512 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        Conv((3, 3), 512 => 512, relu, pad=(1, 1), stride=(1, 1)),
        BatchNorm(512),
        MaxPool((2,2)),
        flatten,
        Dense(512, 4096, relu),
        Dropout(0.5),
        Dense(4096, 4096, relu),
        Dropout(0.5),
        Dense(4096, nclasses)
    ) 
end

# LeNet5 adapted.
function create_LeNet5_Adapted(imgsize, nclasses; st = 2, kt = 4)

    nt = 0
    # Ensure valid parameters.
    if imgsize[3] < kt 
        kt = imgsize[3]
        nt = 1
        st = 1
    else
        nt = floor(Int, (imgsize[3]-kt)/st) + 1
    end

    # Kernels.
    c1_k = (5,5,kt)
    c1_s = (1,1,st)
    c2_k = (5,5,6)
    c2_s = (1,1,6)
    c3_k = ( 
        floor(Int, imgsize[1]/4) - 3, 
        floor(Int, imgsize[2]/4) - 3, 
        16 
    )
    c3_s = (1,1,16)

    # Dimensions.
    z_c1_o = 6 * nt
    z_c2_o = 16 * nt

    # Dense.
    nd = 120 * nt
    ns = floor(Int, 0.7 * nd)

    # Log.
    @info "[LeNet5Adapted][Params] nt: $(nt), kt: $(kt), st: $(st)"
    @info "[LeNet5Adapted][Conv1] Kernel: $(c1_k), Stride: $(c1_s), Z out: $(z_c1_o)"
    @info "[LeNet5Adapted][Conv2] Kernel: $(c2_k), Stride: $(c2_s), Z out: $(z_c2_o)"
    @info "[LeNet5Adapted][Conv3] Kernel: $(c3_k), Stride: $(c3_s), Z out: $(nd)"
    @info "[LeNet5Adapted][Classifier] Dense: $(nd), Sofmax: $(ns)"

    # Create chain.
    return Chain(

        # Image processing.
        Conv(c1_k, imgsize[3]=>z_c1_o, relu, stride=c1_s),
        MeanPool((2,2,1), stride=(2,2,1)),
        Conv(c2_k, z_c1_o=>z_c2_o, relu, stride=c2_s),
        MeanPool((2,2,1), stride=(2,2,1)),
        Conv(c3_k, z_c2_o=>nd, relu, stride=c3_s),

        # Classifier.
        MLUtils.flatten,
        Dense(nd, ns, relu), 
        Dense(ns, nclasses, sigmoid)

    )

end

# LeNet5 original.
function create_LeNet5(imgsize, nclasses)
    out_conv_size = (imgsize[1]÷4 - 3, imgsize[2]÷4 - 3, 16)
    return Chain(
        Conv((5, 5), imgsize[end]=>6, relu),
        MaxPool((2, 2)),
        Conv((5, 5), 6=>16, relu),
        MaxPool((2, 2)),
        flatten,
        Dense(prod(out_conv_size), 120, relu), 
        Dense(120, 84, relu), 
        Dense(84, nclasses)
    )
end

# AlexNet original.
function create_AlexNet(imgsize, nclasses; dropout_prob = 0.5)
    inchannels = imgsize[end]
    return Chain(
        # Backbone.
        Conv((11, 11), inchannels => 96, relu; stride = 4, pad = 2),
        MaxPool((3, 3); stride = 2),
        Conv((5, 5), 96 => 256, relu; pad = 2),
        MaxPool((7, 7); stride = 4),
        Conv((3, 3), 256 => 384, relu; pad = 1),
        Conv((3, 3), 384 => 384, relu; pad = 1),
        Conv((3, 3), 384 => 256, relu; pad = 1),
        MaxPool((3, 3); stride = 2),
        # Classifier.
        MLUtils.flatten,
        Dense(1024, 4096, relu),
        Dropout(dropout_prob),
        Dense(4096, nclasses, relu),
        Dropout(dropout_prob),
        softmax
    )
end

#=
function create_AlexNet(imgsize, nclasses; dropout_prob = 0.5, maxpool1_kernel_stride = 2)
    inchannels = imgsize[end]
    maxpool1_kernel_x = floor(Int, (imgsize[1] - 11) / 4) + 1 - 26 * maxpool1_kernel_stride
    maxpool1_kernel_y = floor(Int, (imgsize[2] - 11) / 4) + 1 - 26 * maxpool1_kernel_stride
    @info "Maxpool1 kernel: ($(maxpool1_kernel_x), $(maxpool1_kernel_y))"
    return Chain(
        # Backbone.
        Conv((11, 11), inchannels => 96, relu; stride = 4, pad = 2),
        MaxPool((maxpool1_kernel_x, maxpool1_kernel_y); stride = maxpool1_kernel_stride),
        Conv((5, 5), 96 => 256, relu; pad = 2),
        MaxPool((3, 3); stride = 2),
        Conv((3, 3), 256 => 384, relu; pad = 1),
        Conv((3, 3), 384 => 384, relu; pad = 1),
        Conv((3, 3), 384 => 256, relu; pad = 1),
        MaxPool((3, 3); stride = 2),
        # Classifier.
        MLUtils.flatten,
        Dense(9216, 4096, relu),
        Dropout(dropout_prob),
        Dense(4096, nclasses),
        Dropout(dropout_prob),
        softmax
    )
end
=#
