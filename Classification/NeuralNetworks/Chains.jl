using MLUtils
using Flux

# Chain types.
@enum ChainType begin 
    LeNet5
    Custom
end

# Create the network chain presented in the example.
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

# Create own network.
function create_network(imgsize, nclasses)
    total_features = imgsize[1] * imgsize[2] * imgsize[3] 
    return Chain(
        Conv((5,5), imgsize[3] => nclasses, relu)  
    )
end
