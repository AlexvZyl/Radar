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
    n_subfeatures
    min_samples_leaf
    min_samples_split
    partial_sampling
end

function create_model(params::TreeParameters)
    return RandomForestClassifier(
        n_trees=params.n_trees, 
        n_subfeatures=params.n_subfeatures,
        partial_sampling=params.partial_sampling,
        min_samples_leaf=params.min_samples_leaf, 
        min_samples_split=params.min_samples_split, 
    )
end

function grid()
    return Dict(
        "n_trees" => 20:20:200,
        "n_subfeatures" => 100:100:1000,
        "partial_sampling" => 0.1:0.1:0.9,
        "min_samples_leaf" => 2:2:20,
        "min_samples_split" => 2:2:20
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

function train(model::RandomForestClassifier, train_x, train_y, test_x, test_y, args, params)
    global current_epoch
    fit!(model, train_x, train_y)
    train_acc, train_loss = evaluate(model, train_x, train_y)
    test_acc, test_loss = evaluate(model, test_x, test_y)
    current = TrainingResults(train_acc, train_loss, test_acc, test_loss, current_epoch)
    update(current, training_state, model, epoch=current_epoch, args=args, progress=false)
    save(training_state, params, args)
    current_epoch += 1
    return -(test_acc+train_acc)
end

function is_optimal(state::TrainingState)
    return state.optimal.epoch == state.current.epoch
end

function save(state, params, args)
    if !is_optimal(state) return end
    path = get_save_path(args)
    path = joinpath(path, "model.txt") 
    touch(path)
    file = open(path, "w")
    write(file, "Optimal parameters for random forests.")
    write(file, "\n--------------------------------------")
    write(file, "\nEpoch: " * string(state.optimal.epoch))
    write(file, "\nN Trees: " * string(params.n_trees))
    write(file, "\nN Subfeatures: " * string(params.n_subfeatures))
    write(file, "\nPartial Sampling: " * string(params.partial_sampling))
    write(file, "\nMin Samples Leaf: " * string(params.min_samples_leaf))
    write(file, "\nMin Samples Split: " * string(params.min_samples_split))
    close(file)
end

function train_random_forests(args::Args)
    # Setup.
    train_x, train_y, test_x, test_y = prepare_data(args)
    training_state.timeout = Inf
    grid_search = grid()
    sampler = RandomSampler()
    global current_epoch
    global training_state
    current_epoch = 0
    training_state = TrainingState()

    @info "Starting hyperopt..."
    @thyperopt for i = args.tree_epochs,
                   sampler = sampler,
                   n_trees = grid_search["n_trees"],
                   n_subfeatures = grid_search["n_subfeatures"],
                   min_samples_leaf = grid_search["min_samples_leaf"],
                   min_samples_split = grid_search["min_samples_split"],
                   partial_sampling = grid_search["partial_sampling"]
        params = TreeParameters(n_trees, n_subfeatures, min_samples_leaf, min_samples_split, partial_sampling)
        model = create_model(params)
        return train(model, train_x, train_y, test_x, test_y, args, params)
    end

end
