using MLUtils
using Flux

# Chain types.
@enum ChainType begin 
    LeNet5
    AlexNet
    Custom
end

# Get the type as a string.
function get_type_string(type::ChainType)
    if type == LeNet5
        return "LeNet5"
    elseif type == Custom
        return "Custom"
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
    else
        @assert false "Invalid model type."
    end
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

# AlexNet.
function create_AlexNet(imgsize, nclasses)
    
end

# Create own network.
function create_network(imgsize, nclasses)
    total_features = imgsize[1] * imgsize[2] * imgsize[3] 
    return Chain(
        Conv((5,5), imgsize[3] => nclasses, relu)  
    )
end
