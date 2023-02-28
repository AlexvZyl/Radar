using Flux: Train
using Base: @kwdef, File
include("NetworkUtils.jl")

Base.@kwdef mutable struct TrainingResults
    train_acc  = 0
    train_loss = 0
    test_acc = 0
    test_loss = 0
end

Base.@kwdef mutable struct TrainingState
    current::TrainingResults = TrainingResults()
    optimal::TrainingResults = TrainingResults()
    max_train::TrainingResults = TrainingResults()
    max_test::TrainingResults = TrainingResults()
end

function acc_score(res::TrainingResults)
    return res.train_acc + res.test_acc
end

function update(new::TrainingResults, state::TrainingState)
    state.current = new 
    
    if new.train_acc > state.max_train.train_acc
        state.max_train = new
    end

    if new.test_acc > state.max_test.test_acc
        state.max_test = new
    end

    if acc_score(new) > acc_score(state.optimal)
        state.optimal = new
    end
end

function save(state::TrainingState, args::Args)
    # Ensure dir exists.
    path = args.savepath
    !ispath(path) && mkpath(path)

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
    write(file, "----------------------------------------------\n")
end

# Train a CNN on the dataset.
function train(chain_type::ChainType; kwargs...)

    # Setup args.
    args = Args(; kwargs...)
    args.savepath = args.savepath * get_type_string(chain_type) * "/" * args.frames_folder * "/"
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
        tblogger = TBLogger(args.savepath, tb_overwrite)
        set_step_increment!(tblogger, 0) ## 0 auto increment since we manually set_step!
        @info "TensorBoard logging at \"$(args.savepath)\""
    end

    # Display meta data.
    image_size = size(train_loader.data[1])[1:3]
    @info "Image size: $(image_size)"
    features = image_size[1] * image_size[2] * image_size[3]
    @info "Features: $(features)"

    # Get the model. 
    model = create_network(chain_type, image_size, length(classes)) |> device

    ## Model and optimiser.
    @info "Model parameters: $(num_params(model))"
    ps = Flux.params(model)
    opt = ADAM(args.η) # Why is my LSP upset about this?  It works fine?
    if args.λ > 0 ## add weight decay, equivalent to L2 regularization
        opt = Optimiser(WeightDecay(args.λ), opt)
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

    # State.
    state = TrainingState()

    ## TRAINING
    @info "Start Training."
    report(0)
    for epoch in 1:args.epochs

        # Train.
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
        current = TrainingResults(train.acc, train.loss, test.acc, test.loss)
        update(current, state)
        save(state, args)

        # Display model performance.
        if epoch % args.infotime == 0 
            report(epoch)
        end

        # Save model to file if at interval.
        if args.checktime > 0 && epoch % args.checktime == 0
            !ispath(args.savepath) && mkpath(args.savepath)
            modelpath = joinpath(args.savepath, "model.bson") 
            let model = cpu(model) ## return model to cpu before serialization
                BSON.@save modelpath model epoch
            end
            @info "Model saved in \"$(modelpath)\""
        end
    end

end
