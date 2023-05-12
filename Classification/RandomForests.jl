using Hyperopt
using DecisionTree
using Base.Threads
using Optim
include("NeuralNetworks/NetworkUtils.jl")
include("NeuralNetworks/Trainer.jl")

global training_state = TrainingState()
global current_epoch = 0

struct TreeParameters
    n_trees
    min_samples_leaf
    min_samples_split
    partial_sampling
end

function create_model(params::TreeParameters)
    return RandomForestClassifier(
        n_trees=params.n_trees, 
        partial_sampling=params.partial_sampling,
        min_samples_leaf=params.min_samples_leaf, 
        min_samples_split=params.min_samples_split, 
    )
end

function grid()
    return Dict(
        "n_trees" => 1:1:100,
        "partial_sampling" => 0.1:0.1:1,
        "min_samples_leaf" => 1:1:100,
        "min_samples_split" => 2:1:100
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

function train(model::RandomForestClassifier, train_x, train_y, test_x, test_y, args)
    global current_epoch
    fit!(model, train_x, train_y)
    train_acc, train_loss = evaluate(model, train_x, train_y)
    test_acc, test_loss = evaluate(model, test_x, test_y)
    current = TrainingResults(train_acc, train_loss, test_acc, test_loss, current_epoch)
    update(current, training_state, model, epoch=current_epoch, args=args, progress=false)
    current_epoch += 1
    return -(test_acc+train_acc)
end

function train_random_forests(args::Args)
    # Setup.
    train_x, train_y, test_x, test_y = prepare_data(args)
    training_state.timeout = Inf
    grid_search = grid()
    sampler = BOHB(dims=[Hyperopt.Continuous(), Hyperopt.Continuous(), Hyperopt.Continuous(), Hyperopt.Continuous()])
    sampler = RandomSampler()

    @thyperopt for i = args.epochs,
                   sampler = sampler,
                   n_trees = grid_search["n_trees"],
                   min_samples_leaf = grid_search["min_samples_leaf"],
                   min_samples_split = grid_search["min_samples_split"],
                   partial_sampling = grid_search["partial_sampling"]
        params = TreeParameters(n_trees, min_samples_leaf, min_samples_split, partial_sampling)
        model = create_model(params)
        return train(model, train_x, train_y, test_x, test_y, args)
    end

end

args = Args(tree=true, persons=1, split=0.7, frames_folder="1-Frames", epochs=10000)
train_random_forests(args)
