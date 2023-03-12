using MLUtils
using Flux

include("Temporal.jl")

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
function create_network(chain_type::ChainType, image_size, n_classes, args::Args)
    if chain_type == LeNet5
        return create_LeNet5(image_size, n_classes)
    elseif chain_type == LeNet5Adapted
        return create_LeNet5_Adapted(image_size, n_classes, args)
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

# LeNet5 adapted.
function create_LeNet5_Adapted(imgsize, nclasses, args::Args)

    layers = gen_lenet_layers(imgsize, args)

    display("C1:")
    display(layers["c1"])
    display("A1:")
    display(layers["a1"])
    display("C2:")
    display(layers["c2"])
    display("A2:")
    display(layers["a2"])
    display("C3:")
    display(layers["c3"])

    nd = Int(prod(layers["c3"].output_size) * layers["c3"].channels)
    ns = floor(Int, 0.7*nd)

    # Create chain.
    return Chain(
        # Image processing.
        flux(layers["c1"]),
        flux(layers["a1"]),
        flux(layers["c2"]),
        flux(layers["a2"]),
        flux(layers["c3"]),
        # Classifier.
        MLUtils.flatten,
        Dense(nd, ns), 
        relu,
        Dense(ns, nclasses),
        softmax
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
        Dense(84, nclasses),
        softmax,
    )
end

# AlexNet original.
function create_AlexNet(imgsize, nclasses; dropout_prob = 0.5)
    inchannels = imgsize[end]
    return Chain(

        Conv((11, 11), inchannels=>96; stride=4),
        relu,
        MaxPool((3, 3); stride=2),

        Conv((5, 5), 96=>256; pad=2),
        relu,
        MaxPool((3, 3); stride=2),

        Conv((3, 3), 256=>384; pad=1),
        relu,
        Conv((3, 3), 384=>384; pad=1),
        relu,
        Conv((3, 3), 384=>256; pad=1),
        relu,
        MaxPool((3, 3); stride=2),

        MLUtils.flatten,
        Dense(7680, 4096),
        relu,
        Dropout(dropout_prob),

        Dense(4096, 4096),
        relu,
        Dropout(dropout_prob),

        Dense(4096, nclasses),
        softmax
    )
end
