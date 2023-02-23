using MLUtils
using Flux

# Chain types.
@enum ChainType begin 
    LeNet5
    AlexNet
    VGG16
    Custom
end

# Get the type as a string.
function get_type_string(type::ChainType)
    if type == LeNet5
        return "LeNet5"
    elseif type == Custom
        return "Custom"
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
    if chain_type == LeNet5
        return create_LeNet5(image_size, n_classes)
    elseif chain_type == Custom
        return create_network(image_size, n_classes)
    elseif chain_type == AlexNet
        return create_AlexNet(image_size, n_classes)
    elseif chain_type == VGG16
        return create_VGG16(image_size, n_classes)
    else
        @assert false "Invalid model type."
    end
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

# LeNet5.
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

function create_AlexNet(imgsize, nclasses; dropout_prob = 0.5, maxpool1_kernel_stride = 2)
    inchannels = imgsize[end]
    maxpool1_kernel_x = floor(Int, (imgsize[1] - 11) / 4) + 1 - 26 * maxpool1_kernel_stride
    maxpool1_kernel_y = floor(Int, (imgsize[2] - 11) / 4) + 1 - 26 * maxpool1_kernel_stride
    println("Kernel X: ", maxpool1_kernel_x)
    println("Kernel Y: ", maxpool1_kernel_y)
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
        Dropout(dropout_prob),
        Dense(9216, 4096, relu),
        Dropout(dropout_prob),
        Dense(4096, nclasses),
        Dropout(dropout_prob),
        softmax
    )
end

# Create own network.
function create_network(imgsize, nclasses)
    total_features = imgsize[1] * imgsize[2] * imgsize[3] 
    return Chain(
        Conv((5,5), imgsize[3] => nclasses, relu)  
    )
end
