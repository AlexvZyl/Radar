using Base: product
using ScikitLearn
using DecisionTree
using Base.Threads
include("NeuralNetworks/NetworkUtils.jl")
include("NeuralNetworks/Trainer.jl")

struct TreeParameters
    n_trees
    min_samples_leaf
    min_samples_split
    min_purity_increase
end

function default_params()
    TreeParameters(10, 1, 2, 0.0)
end

function create_model(params::TreeParameters)
    return RandomForestClassifier(
        n_trees=params.n_trees, 
        min_samples_leaf=params.min_samples_leaf, 
        min_samples_split=params.min_samples_split, 
        min_purity_increase=params.min_purity_increase
    )
end

function grid()
    return Dict(
        "n_trees" => 1:20,
        "min_samples_leaf" => 1:5,
        "min_samples_split" => 2:5,
        "min_purity_increase" => 0:0.5:5
    )
end

function evaluate(model, x, y)
    predictions = predict(model, x)
    acc = sum(predictions .== y) / length(y)
    l = loss(predictions, y)
    return acc, l
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

function train(model::RandomForestClassifier, train_x, train_y, test_x, test_y, state, epoch)
    fit!(model, train_x, train_y)
    train_acc, train_loss = evaluate(model, train_x, train_y)
    test_acc, test_loss = evaluate(model, test_x, test_y)
    current = TrainingResults(train_acc, train_loss, test_acc, test_loss, epoch)
    update(current, state, model, epoch=epoch, args=args)
end

function train_random_forests(args::Args)
    # Setup.
    train_x, train_y, test_x, test_y = prepare_data(args)
    state = TrainingState()
    state.timeout = Inf
    grid_seach = grid()
    epoch = 0
    total_epochs = length(grid_seach["n_trees"])*length(grid_seach["min_samples_leaf"])*length(grid_seach["min_samples_split"])*length(grid_seach["min_purity_increase"])

    # Grid search.
    for n_trees in grid_seach["n_trees"]
        for min_samples_leaf in grid_seach["min_samples_leaf"]
            for min_samples_split in grid_seach["min_samples_split"]
                @threads for min_puroty_increase in grid_seach["min_purity_increase"]
                    model = create_model(TreeParameters(n_trees, min_samples_leaf, min_samples_split, min_puroty_increase)) 
                    train(model, train_x, train_y, test_x, test_y, state, epoch) 
                    epoch+=1
                end
                @info "Progress: $((epoch/total_epochs)*100)%"
            end
        end
    end
end

args = Args(tree=true, persons=1, split=0.7, frames_folder="5-Frames")
train_random_forests(args)
