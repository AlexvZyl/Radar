include("NetworkUtils.jl")
include("Chains.jl")

# Train a CNN on the dataset.
function train(chain_type::ChainType; kwargs...)

    # Setup args.
    args = Args(; kwargs...)
    args.seed > 0 && Random.seed!(args.seed)
    use_cuda = args.use_cuda && CUDA.functional()

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
    train_loader, test_loader, classes = get_data_loaders(args, split_at = args.split)
    training_samples_count = size(train_loader.data[1])[4]
    @info "Training samples: $(training_samples_count)"
    @info "Testing samples: $(size(test_loader.data[1])[4])"

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
    model = nothing
    if chain_type == ChainType::Custom
        model = create_LeNet5(image_size, length(classes)) |> device
    elseif chain_type == ChainType::CNN
        model = create_network(image_size, length(classes)) |> device
    else
        @assert false "Invalid model type."
    end

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

    ## TRAINING
    @info "Start Training."
    report(0)
    for epoch in 1:args.epochs
        # Train.
        @showprogress for (x, y) in train_loader
            x, y = x |> device, y |> device
            gs = Flux.gradient(ps) do
                    ŷ = model(x)
                    loss(ŷ, y)
                end
            Flux.Optimise.update!(opt, ps, gs)
        end
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
