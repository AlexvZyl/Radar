using Flux: Train, Optimisers
using Base: @kwdef, File
using Flux

include("NetworkUtils.jl")

function acc_score(res::TrainingResults)
    return res.train_acc + res.test_acc
end

function update(new::TrainingResults, state::TrainingState, model; epoch::Number=0, args::Args = nothing)
    state.current = new 
    @info new
    
    # New optimal training state.
    if acc_score(new) > acc_score(state.optimal)
        consecutive = state.optimal.epoch+1 == epoch
        state.optimal = new

        # Verbose tracking.
        if (new.train_acc > state.max_train.train_acc) || ((new.train_acc == state.max_train.train_acc) && (new.test_acc > state.max_train.test_acc))
            state.max_train = new
        end
        if (new.test_acc > state.max_test.test_acc) || ((new.test_acc == state.max_test.test_acc) && (new.train_acc > state.max_test.train_acc))
            state.max_test = new
        end

        # Logging.
        if !consecutive println() end
        @info "[$epoch]  Train: (acc=$(new.train_acc))  Test: (acc=$(new.test_acc))"
        if isnothing(args) return
        !ispath(args.savepath) && mkpath(args.savepath)
            modelpath = joinpath(args.savepath, "model.bson") 
            let model = cpu(model)
                BSON.@save modelpath model epoch
            end
        end

    else
        print("[", epoch, "] ")
    end

    save(state, args)
    return (epoch - state.optimal.epoch) > state.timeout
end

function save(state::TrainingState, args::Args)
    path = get_save_path(args)

    # Setup file.
    state_path = joinpath(path, "state.txt") 
    # rm(state_path)
    touch(state_path)
    file = open(state_path, "w")

    # Write contents.
    write(file, "Current\n")
    save(state.current, file)
    write(file, "Optimal\n")
    save(state.optimal, file)
    write(file, "Training Maximum Accuracy\n")
    save(state.max_train, file)
    write(file, "Testing Maximum Accuracy\n")
    save(state.max_test, file)

    close(file)
end

function save(res::TrainingResults, file::IOStream)
    write(file, "----------------------------------------------\n")
    write(file, string("Training Accuracy: ", res.train_acc, "\n"))
    write(file, string("Training Loss: ", res.train_loss, "\n"))
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
    @info "Train ratio: $(args.split)"
    train_loader, test_loader, classes = get_data_loaders(args)
    training_samples_count = size(train_loader.data[1])[end]
    @info "Training samples: $(training_samples_count)"
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
    @info "Model parameters: $(num_params(model))"
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
        train = eval_loss_accuracy(train_loader, model, device)
        test = eval_loss_accuracy(test_loader, model, device)        
        println("Epoch: $epoch   Train: $(train)   Test: $(test)")
        if args.tblogger
            set_step!(tblogger, epoch)
            with_logger(tblogger) do
                @info "Train" loss=train.loss  acc=train.acc
                @info "Test"  loss=test.loss   acc=test.acc
            end
        end
    end

    train_data_size = sizeof(train_loader.data[1]) / 1e6 # Mb
    @info "Train data size: $(train_data_size) Mb"
    batch_size = train_data_size / (training_samples_count / args.batchsize)
    @info "Batch size: $(batch_size) Mb"

    ## TRAINING
    state = TrainingState()
    state.timeout = args.timeout
    @info "Start Training."
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

        train = eval_loss_accuracy(train_loader, model, device)
        test = eval_loss_accuracy(test_loader, model, device)        
        current = TrainingResults(train.acc, train.loss, test.acc, test.loss, epoch)
        if update(current, state, model, epoch=epoch, args=args) break end

    end

end
