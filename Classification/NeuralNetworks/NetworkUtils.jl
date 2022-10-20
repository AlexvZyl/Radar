include("../Utilities.jl")
using MLUtils
using Flux
using Flux.Data: DataLoader
using Flux.Optimise: Optimiser, WeightDecay, Adam
using Flux: onehotbatch, onecold, flatten
using Flux.Losses: logitcrossentropy
using Statistics, Random
using Logging: with_logger
using TensorBoardLogger: TBLogger, tb_overwrite, set_step!, set_step_increment!
using ProgressMeter: @showprogress
import MLDatasets
import BSON
using CUDA
using JLD2

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
    split = 0.8          ## Train/test split
end

# Utility functions.
num_params(model) = sum(length, Flux.params(model))
round4(x::Number) = round(x, digits = 4)

# Format the different frames so that everything is contained in one matrix.
function combine(instances::Vector{Vector{AbstractMatrix}})
    # Get meta data.
    image_size = size(instances[1][1])
    frames = size(instances[1])[1]
    data_type = typeof(instances[1][1])
    total_matrix = Array{data_type, 4}(undef, image_size[1], image_size[2], frames, 0)
    # Create the new 4D matrix.
    for i in instances
        # Create instance matrix containing all of the frames.
        instance_matrix = Array{data_type, 3}(undef, image_size[1], image_size[2], 0)
        for m in i
            instance_matrix = cat(instance_matrix, reshape(m, (image_size[1], image_size[2], 1)), dims = 3)
        end
        # Add instance to total 4D matrix.
        total_matrix = cat(total_matrix, reshape(instance_matrix, (image_size[1], image_size[2], frames, :)), dims = 4)
    end
    convert(Array{ComplexF64, 4}, total_matrix)
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
    frames_count = size(frames_data[1][1])[1]
    image_size = size(frames_data[1][1][1])
    train_x = Array{ComplexF64, 4}(undef, image_size[1], image_size[2], frames_count, 0)
    test_x = Array{ComplexF64, 4}(undef, image_size[1], image_size[2], frames_count, 0)
    train_y = Vector{Int32}(undef, 0)
    test_y = Vector{Int32}(undef, 0)
    # Combine the frames into on large matrix, with labels.
    for (c, _) in enumerate(frames_data)
        # Combine and split frames data.
        combined_data = combine(frames_data[c])
        tr_x, tst_x = splitobs(combined_data, at = split_at)
        # Labels.
        if labels == false
            tr_y = [ c for _ in 1:1:size(tr_x)[4] ]
            tst_y = [ c for _ in 1:1:size(tst_x)[4] ]
        else
            tr_y = [ labels[c] for _ in 1:1:size(tr_x)[4] ]
                tst_y = [ labels[c] for _ in 1:1:size(tst_x)[4] ]
        end
        # Add to total.
        train_x = cat(train_x, tr_x, dims = 4) 
        test_x = cat(test_x, tst_x, dims = 4) 
        train_y = cat(train_y, tr_y, dims = 1) 
        test_y = cat(test_y, tst_y, dims = 1) 
    end
    train_y = onehotbatch(train_y, 1:4)
    test_y = onehotbatch(test_y, 1:4)
    return train_x, train_y, test_x, test_y
end

# Load the data from the jdl files and prepare them for training.
# Preparation includes using `Flux.DataLoader()`.
function get_data_loaders(args::Args; split_at = 0.7)

    @info "Processing data..."

    classes = get_elevated_folder_list()
    # @info "Classes: " classes
    # Format of `frames_data`:
    # Vector                        - Classes (folders)
    #   Vector                      - Iterations
    #       Vector                  - Frames
    #           AbstractMatrix      - Frame
    frames_data = load_doppler_frames_from_folder.(classes)

    # Format the data (combine matrices, assign labels).
    train_x, train_y, test_x, test_y = format_and_split_data(frames_data, split_at = split_at)
    train_x = abs.(train_x)
    test_x = abs.(test_x)
    frames_data = nothing # Free memory.
    # Generate the Flux loaders.
    train_loader = DataLoader((train_x, train_y), batchsize = args.batchsize, shuffle = true) 
    test_loader = DataLoader((test_x, test_y), batchsize = args.batchsize) 

    return train_loader, test_loader, classes

end

# Calculate the loss.
loss(ŷ, y) = logitcrossentropy(ŷ, y)

# Calculate the accuracy and loss of the network.
function eval_loss_accuracy(loader, model, device)
    l = 0f0
    acc = 0
    ntot = 0
    for (x, y) in loader
        x, y = x |> device, y |> device
        ŷ = model(x)
        l += loss(ŷ, y) * size(x)[end]        
        acc += sum(onecold(ŷ |> cpu) .== onecold(y |> cpu))
        ntot += size(x)[end]
    end
    return (loss = l/ntot |> round4, acc = acc/ntot*100 |> round4)
end
