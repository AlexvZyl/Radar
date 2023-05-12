using Base: product
using ScikitLearn
using DecisionTree
include("NeuralNetworks/NetworkUtils.jl")

function evaluate(model, x, y)
    return sum(predict(model, x) .== y) / length(y)
end

function prepare_for_tree(array::AbstractArray{T,N}) where {T,N}
    ar_size = size(array)
    new_size = reduce(*, ar_size[1:end-1])
    new = Array{T,2}(undef, new_size, ar_size[end])
    for d in 1:ar_size[N]    
        new[:,d] = reshape(array[:,:,:,d], new_size)
    end
    return transpose(new)
end

function prepare_data(args::Args)
    train_x, train_y, test_x, test_y, _ = get_data_loaders(args)
    train_y = Vector(Int.(train_y.indices))
    test_y = Vector(Int.(test_y.indices))
    train_x = prepare_for_tree(train_x)
    test_x = prepare_for_tree(test_x)
    return train_x, train_y, test_x, test_y
end

function random_forests(args::Args)
    train_x, train_y, test_x, test_y = prepare_data(args)
    model = RandomForestClassifier()
    fit!(model, train_x, train_y)
    accuracy = evaluate(model, test_x, test_y)
    println("accuracy: $accuracy")
end

args = Args(tree=true, persons=1, split=0.7, batchsize=8, epochs=1000, frames_folder="5-Frames")
random_forests(args)
