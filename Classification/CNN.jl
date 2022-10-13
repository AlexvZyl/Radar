include("Utilities.jl")

# Packages used in the example.
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
function load_doppler_frames(folder::String)
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

# Load the data from the jdl files and prepare them for training.
# Preparation includes using `Flux.DataLoader()`.
function get_prepared_data(args::Args)

    classes = get_elevated_folder_list()
    @info "Classes: " classes
    # Format of `frames_data`:
    # Vector                        - Classes (folders)
    #   Vector                      - Iterations
    #       Vector                  - Frames
    #           AbstractMatrix      - Frame
    frames_data = load_doppler_frames.(classes)

    # The data has to be in a tuple with `features` and `targets`.
    # features = the data.
    # targets = the labels.
    # See flow `display` for example.
    formatted_data = (
        features = Vector{Array{ComplexF64, 3}}(undef, 0),
        targets = Vector{Int32}(undef, 0)
    )

    # Combine the frames into on large matrix, with labels.
    for (c, _) in enumerate(frames_data)
        for (i, _) in enumerate(frames_data[c])
            push!(formatted_data[:features], combine(frames_data[c][i]))
            push!(formatted_data[:targets], get_one_hot_index(classes, classes[c]))
        end
    end

    # Load the data for Flux.
    loader = DataLoader((formatted_data[:features], formatted_data[:targets]), batchsize = args.batchsize, shuffle = true) 

end

# Create the network chain.
function create_network()
    return Chain(
        Conv((5,5))
    )
end

# Train a CNN on the dataset.
function train(; kwargs...)

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
    data = get_prepared_data(args)

end

# Run the training script.
train()
