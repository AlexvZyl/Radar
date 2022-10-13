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
# import MLDatasets
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

# Load the data from the jdl files and prepare them for training.
function get_prepared_data()
    classes = get_elevated_folder_list()
    # Format of `frames_data`:
    # Vector                        - Classes (folders)
    #   Vector                      - Iterations
    #       Vector                  - Frames
    #           AbstractMatrix      - Frame
    frames_data = load_doppler_frames.(classes)
    return frames_data
end

# Utility functions.
num_params(model) = sum(length, Flux.params(model))
round4(x::Number) = round(x, digits = 4)

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
end

# Only execute when included as a script.
if abspath(PROGRAM_FILE) == @__FILE__ 
    train()
end
