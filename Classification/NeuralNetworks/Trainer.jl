using MLJ: CategoricalArrays
using Flux: Train, Optimisers
using Base: @kwdef, File
using Flux
using MLJ
using CategoricalArrays
include("NetworkUtils.jl")

function acc_score(res::TrainingResults) return res.train_acc + res.val_acc end

function update(new::TrainingResults, state::TrainingState, model; epoch::Number=0, args::Args = nothing, progress = true, val_cf = nothing)
    state.current = new 
    
    # New optimal training state.
    if acc_score(new) > acc_score(state.optimal)
        state.optimal = new
        state.validation_optimal_cf = val_cf

        # Verbose tracking.
        if (new.train_acc > state.max_train.train_acc) || ((new.train_acc == state.max_train.train_acc) && (new.test_acc > state.max_train.test_acc))
            state.max_train = new
        end
        if (new.val_acc > state.max_val.val_acc) || ((new.val_acc == state.max_val.val_acc) && (new.train_acc > state.max_test.train_acc))
            state.max_test = new
        end

        # Actually optimal.
        if (new.test_acc > state.max_test.test_acc)
            state.max_test = new
        end

        # Logging.
        @info "Optimal" state.optimal
        if isnothing(args) return end
        path = get_save_path(args)
        !ispath(path) && mkpath(path)
        if !args.tree
            modelpath = joinpath(path, "model.bson") 
            let model = cpu(model)
                BSON.@save modelpath model epoch
            end
        end

    else
        progress && @info new
    end

    save(state, args)
    return (epoch - state.optimal.epoch) > state.timeout
end

function save(state::TrainingState, args::Args)
    path = get_save_path(args)

    # Setup file.
    state_path = joinpath(path, "state.txt") 
    touch(state_path)
    file = open(state_path, "w")

    # Write contents.
    write(file, "Current\n")
    save(state.current, file)
    write(file, "Optimal\n")
    save(state.optimal, file)
    write(file, "Training Maximum Accuracy\n")
    save(state.max_train, file)
    write(file, "Validation Maximum Accuracy\n")
    save(state.max_val, file)
    write(file, "Testing Maximum Accuracy\n")
    save(state.max_test, file)

    write(file, "\nModel parameters: ", string(args.model_params))
    write(file, "\nValidation Confusion matrix: ", string(state.validation_optimal_cf))
    write(file, "\nTesting Confusion matrix: ", string(state.testing_optimal_cf))

    close(file)
end

function save(res::TrainingResults, file::IOStream)
    write(file, "----------------------------------------------\n")
    write(file, string("Training Accuracy: ", res.train_acc, "\n"))
    write(file, string("Training Loss: ", res.train_loss, "\n"))
    write(file, string("Validation Accuracy: ", res.val_acc, "\n"))
    write(file, string("Validation Loss: ", res.val_loss, "\n"))
    write(file, string("Testing Accuracy: ", res.test_acc, "\n"))
    write(file, string("Testing Loss: ", res.test_loss, "\n"))
    write(file, string("Epoch: ", res.epoch, "\n"))
    write(file, "----------------------------------------------\n")
end

# Train a CNN on the dataset.
function train(chain_type::ChainType; kwargs...)

    # Setup args.
    args = Args(; kwargs...)
    args.seed > 0 && Random.seed!(args.seed)
    use_cuda = args.use_cuda && CUDA.functional()
    args.model = chain_type

    # Display training device.
    if use_cuda
        device = gpu
        @info "Training on GPU."
    else
        device = cpu
        @error "Training on CPU."
    end

    # Get the data.
    @info "Train/Val/Test: $(args.train_ratio)/$(args.val_ratio)/$(args.test_ratio)"
    train_loader, val_loader, test_loader, classes = get_data_loaders(args)
    @info "Training samples: $(size(train_loader.data[1])[end])"
    @info "Validation samples: $(size(val_loader.data[1])[end])"
    @info "Testing samples: $(size(test_loader.data[1])[end])"

    ## LOGGING UTILITIES
    if args.tblogger 
        tblogger = TBLogger(get_save_path(args), tb_overwrite)
        set_step_increment!(tblogger, 0) ## 0 auto increment since we manually set_step!
        @info "TensorBoard logging at \"$(get_save_path(args))\""
    end

    # Display meta data.
    image_size = size(train_loader.data[1])[1:3]
    @info "Image size: $(image_size)"
    features = image_size[1] * image_size[2] * image_size[3]
    @info "Features: $(features)"

    # Get the model. 
    model = create_network(chain_type, image_size, length(classes), args) |> device

    ## Model and optimiser.
    args.model_params = num_params(model)
    @info "Model parameters: $(args.model_params)"
    ps = Flux.params(model)
    # Weight decay.
    opt = nothing
    if args.λ > 0 
        opt = Flux.Optimise.AdamW(args.η, (0.9, 0.999), args.λ)
    else
        opt = Flux.Optimise.Adam(args.η)
    end

    ## Reporting.
    function report(epoch)
        train, _ = eval_loss_accuracy(train_loader, model, device)
        val, _ = eval_loss_accuracy(val_loader, model, device)        
        println("Epoch: $epoch   Train: $(train)   Test: $(val)")
        if args.tblogger
            set_step!(tblogger, epoch)
            with_logger(tblogger) do
                @info "Train" loss=train.loss  acc=train.acc
                @info "Validation"  loss=val.loss   acc=val.acc
            end
        end
    end

    ## TRAINING
    state = TrainingState()
    state.timeout = args.timeout
    @info "Starting Training."
    report(0)
    for epoch in 1:args.epochs

        # Zygote.
        for (x, y) in train_loader
            x, y = x |> device, y |> device
            gs = Flux.gradient(ps) do
                ŷ = model(x)
                loss(ŷ, y)
            end
            Flux.Optimise.update!(opt, ps, gs)
        end

        train, _ = eval_loss_accuracy(train_loader, model, device)
        val, y_hat_val = eval_loss_accuracy(val_loader, model, device)        
        val_cf = confusion_mat(val_loader, y_hat_val)
        current = TrainingResults(train.acc, train.loss, val.acc, val.loss, 0, 0, epoch)
        if update(current, state, model, epoch=epoch, args=args, val_cf=val_cf)
            # Now get the testing accuracy.
            optimal_model = BSON.load(get_save_path(args) * "model.bson")[:model] |> gpu
            test, y_hat_test = eval_loss_accuracy(test_loader, optimal_model, device)
            test_cf = confusion_mat(test_loader, y_hat_test)
            state.optimal.test_acc   = test.acc
            state.optimal.test_loss  = test.loss
            state.testing_optimal_cf = test_cf
            save(state, args)
            break 
        end

    end
end

function confusion_mat(loader, hat)
    y_total = vcat([ onecold(l[2]) for l in loader ]...)
    y_total = CategoricalArray(y_total, ordered=true)
    y_hat_val = CategoricalArray(hat, ordered=true)
    return ConfusionMatrix()(y_hat_val, y_total)
end
