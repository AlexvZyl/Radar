include("Utilities.jl")

using MLUtils
using Flux
using Flux.Data: DataLoader
using Flux.Optimise: Optimiser, WeightDecay
using Flux: onehotbatch, onecold, flatten
using Flux.Losses: logitcrossentropy
using Statistics, Random
using Logging: with_logger
using TensorBoardLogger: TBLogger, tb_overwrite, set_step!, set_step_increment!
using ProgressMeter: @showprogress
import MLDatasets
import BSON
using CUDA

# Arguments used.
Base.@kwdef mutable struct Args
    η = 3e-4             ## learning rate
    λ = 0                ## L2 regularizer param, implemented as weight decay
    batchsize = 128      ## batch size
    epochs = 10          ## number of epochs
    seed = 0             ## set seed > 0 for reproducibility
    use_cuda = true      ## if true use cuda (if available)
    infotime = 1 	     ## report every `infotime` epochs
    checktime = 5        ## Save the model every `checktime` epochs. Set to 0 for no checkpoints.
    tblogger = true      ## log training with tensorboard
    savepath = "Runs/"   ## results path (relative)
end

# Utility functions.
num_params(model) = sum(length, Flux.params(model))
round4(x::Number) = round(x, digits = 4)

# Format the different frames so that everything is contained in one matrix.
function combine(matrices::Vector{AbstractMatrix})
    matrix_size = size(matrices[1])
    new_matrix = Array{typeof(matrices[1][1]), 3}(undef, matrix_size[1], matrix_size[2], 0)
    for m in matrices
        new_matrix = cat(new_matrix, reshape(m, (matrix_size[1], matrix_size[2], 1)), dims = 3)
    end
    new_matrix
end

# Load the doppler frames from the folder into a vector.
# All of the numbers below should be doubled when using the complex numbers
# and not the magnitudes.
# 110 000 000 samples per measurement (complex samples).
# 556 480 pixels per measurement.
function load_doppler_frames_from_folder(folder::String)
    map_dir = get_directories(folder)[3]
    files = get_all_files(map_dir, true)  
    doppler_frames = Vector{Vector{AbstractMatrix}}()
    for file in files
        push!(doppler_frames, load(file)["Doppler FFT Frames"])
    end
    return doppler_frames
end

# Get the index related to the label.
function get_one_hot_index(labels, label)
    for (i, _) in enumerate(labels)
        if labels[i] == label
            return i
        end
    end
    @assert false "Label not found."
end

# Format the data for the DataLoader and split for training and testing.
function format_and_split_data(frames_data; labels = false, split_at = 0.7)
    train_x = Vector{Array{ComplexF64, 3}}(undef, 0)
    test_x = Vector{Array{ComplexF64, 3}}(undef, 0)
    train_y = Vector{Int32}(undef, 0)
    test_y = Vector{Int32}(undef, 0)
    # Combine the frames into on large matrix, with labels.
    for (c, _) in enumerate(frames_data)
        # Combine and split frames data.
        tr_x, tst_x = Vector.(splitobs(combine.(frames_data[c]), at = split_at))
        # Labels.
        if labels == false
            tr_y = [ c for _ in 1:1:length(tr_x) ]
            tst_y = [ c for _ in 1:1:length(tst_x) ]
        else
            tr_y = [ labels[c] for _ in 1:1:length(tr_x) ]
            tst_y = [ labels[c] for _ in 1:1:length(tst_x) ]
        end
        # Add to total.
        train_x = vcat(train_x, tr_x) 
        train_y = vcat(train_y, tr_y) 
        test_x = vcat(test_x, tst_x) 
        test_y = vcat(test_y, tst_y) 
    end
    return train_x, train_y, test_x, test_y
end

# Load the data from the jdl files and prepare them for training.
# Preparation includes using `Flux.DataLoader()`.
function get_data_loaders(args::Args; split_at = 0.7)

    classes = get_elevated_folder_list()
    # @info "Classes: " classes
    # Format of `frames_data`:
    # Vector                        - Classes (folders)
    #   Vector                      - Iterations
    #       Vector                  - Frames
    #           AbstractMatrix      - Frame
    frames_data = load_doppler_frames_from_folder.(classes)

    # Format the data (combine matrices, assign labels).
    train_x, train_y, test_x, test_y = format_and_split_data(frames_data, labels = classes, split_at = split_at)
    frames_data = nothing # Free memory.
     
    # Generate the Flux loaders.
    train_loader = DataLoader((train_x, train_y), batchsize = args.batchsize, shuffle = true) 
    test_loader = DataLoader((test_x, test_y), batchsize = args.batchsize, shuffle = true) 
    return train_loader, test_loader, classes

end

# Create the network chain.
function create_network(imgsize, nclasses)
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

# Train a CNN on the dataset.
function train(; kwargs...)

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
    train_loader, test_loader, classes = get_data_loaders(args, split_at = 0.8)
    @info "Training samples: $(length(train_loader.data[1]))"
    @info "Testing samples: $(length(test_loader.data[1]))"

    # Get the image size.
    image_size = size(train_loader.data[1][1])
    @info "Image size: $(image_size)"
    features = image_size[1] * image_size[2] * image_size[3]
    @info "Features: $(features)"

    # Create and pass network to device.
    network = create_network(image_size, length(classes)) |> device
    @info "Network parameters: $(num_params(network))"

end

# Run the training script.
train()
