using ScikitLearn
using DecisionTree
include("NeuralNetworks/NetworkUtils.jl")

function prepare_for_tree_(array::AbstractArray{T,N}) where {T,N}
    ar_size = size(array)
    new_2d = (ar_size[1], ar_size[2]*ar_size[3])
    new = Array{T,N-1}(undef, new_2d..., ar_size[end])
    for d in 1:ar_size[N]    
        new[:,:,d] = reshape(array[:,:,:,d], new_2d...)
    end
    return new
end

function prepare_data(args::Args)
    train_x, train_y, test_x, test_y, labels = get_data_loaders(args)
    train_y = Vector(Int.(train_y.indices))
    test_y = Vector(Int.(test_y.indices))
    train_y = [ labels[i] for i in train_y ]
    test_y = [ labels[i] for i in test_y ]
    train_x = prepare_for_tree_(train_x)
    test_x = prepare_for_tree_(test_x)
    return test_x, test_y, train_x, train_y
end

function random_forests(args::Args)
    test_x, test_y, train_x, train_y = prepare_data(args)
    model = DecisionTreeClassifier()
    fit!(model, train_x, train_y)
end

args = Args(tree=true, persons=1, split=0.7, batchsize=8, epochs=1000, frames_folder="5-Frames")
random_forests(args)
