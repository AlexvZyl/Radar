using MLUtils
using Flux

include("Temporal.jl")

# Get the type as a string.
function get_type_string(type::ChainType)
    if type == LeNet5 return "LeNet5"
    elseif type == LeNet5StandardTemporal return "LeNet5StandardTemporal"
    elseif type == LeNet5Temporal return "LeNet5Temporal"
    elseif type == AlexNet return "AlexNet"
    else @assert false "Invalid chain type."
    end
end

# Create the network given the type.
function create_network(chain_type::ChainType, image_size, n_classes, args::Args)
    if chain_type == LeNet5 return create_LeNet5(image_size, n_classes)
    elseif chain_type == LeNet5StandardTemporal return create_LeNet5_standard_temporal(image_size, n_classes)
    elseif chain_type == LeNet5Temporal return create_LeNet5_temporal(image_size, n_classes)
    elseif chain_type == AlexNet return create_AlexNet(image_size, n_classes, dropout_prob=args.dropout)
    else @assert false "Invalid model type."
    end
end

# LeNet5 adapted.
function create_LeNet5_temporal(imgsize, nclasses)

    layers = gen_lenet_layers(imgsize)
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
    return Chain(
        #--
        Conv((9, 9), imgsize[end]=>6, stride=3),
        relu,
        MeanPool((3, 3), stride=3),
        #--
        Conv((5, 5), 6=>16),
        relu,
        MeanPool((2, 2), stride=2),
        #--
        Conv((5,5), 16=>120),
        relu,
        flatten,
        #--
        Dense(1680, 84), 
        relu,
        Dense(84, nclasses),
        softmax,
        #--
    )
end

function output_z(kernel_count, z_in, kernel_z, stride_z, padding_z)
    return kernel_count*(floor(Int, (z_in + 2*padding_z - kernel_z)/stride_z)+1)
end

function create_LeNet5_standard_temporal(imgsize, nclasses)
    img_z = imgsize[end]
    conv1_z = img_z > 4 ? 4 : 2
    conv1_o = output_z(1, img_z, conv1_z, 1, 0)
    conv2_z = conv1_o > 2 ? 2 : 1
    conv2_o = output_z(1, conv1_o, conv2_z, 1, 0)
    return Chain(
        #--
        Conv((9,9,conv1_z), 1=>6, stride=(3,3,1)),
        relu,
        MeanPool((3,3,1), stride=(3,3,1)),
        #--
        Conv((5,5,conv2_z), 6=>16),
        relu,
        MeanPool((2,2,1), stride=(2,2,1)),
        #--
        Conv((5,5,conv2_o), 16=>120),
        relu,
        flatten,
        #--
        Dense(1680, 84), 
        relu,
        Dense(84, nclasses),
        softmax,
        #--
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
