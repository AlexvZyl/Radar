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
using Base.Threads

include("../Utilities.jl")
include("Chains.jl")

persons_string(args::Args) = args.persons == 1 ? "1-Person" : "2-Persons"
temporal_string(args::Args) = args.temporal ? "Temporal" : "Standard"

function get_save_path(args::Args)
    path = args.save_path_parent * "/" * temporal_string(args) * "/" * persons_string(args) * "/" * get_type_string(args.model) * "/" * args.frames_folder * "/"
    !ispath(path) && mkpath(path)
    return path
end

# Labels used in the classification.
function get_labels()
    return String["Walking", "Jogging", "WalkingStick", "JoggingStick", "Clutter"]
end

# Determiine the classification label based on the folder label.
# Need this since some of the folders are being thrown togther.
function parse_label(label::String)
    labels = get_labels()
    if label == labels[end] return label end
    if occursin("Stick", label)
        if occursin("Walking", label)
            return labels[3]
        else
            return labels[4]
        end
    else
        if occursin("Walking", label)
            return labels[1]
        else
            return labels[2]
        end
    end
    @assert false "Invalid label."
end

# Utility functions.
num_params(model) = sum(length, Flux.params(model))
round4(x::Number) = round(x, digits = 4)

# Format the different frames so that everything is contained in one matrix.
function combine(class_samples::Vector{Vector{AbstractMatrix}})

    # Get meta data.
    image_size = size(class_samples[1][1])
    frame_count = length(class_samples[1])
    data_type = typeof(class_samples[1][1])
    class_matrix = Array{data_type, 4}(undef, image_size[1], image_size[2], frame_count, 1)

    # Create the new 4D matrix.
    for (s, sample) in enumerate(class_samples)
        for (f, frame) in enumerate(sample)
            class_matrix[s][f] = reshape(frame, (image_size[1], image_size[2], 1))
        end
    end

    return class_matrix 

end

# Load the doppler frames from the folder into a vector.
function load_classes_from_folders(folders::Vector{String}, subdirectory::String = "")

    doppler_frames = Dict{String, Vector{Vector{AbstractMatrix}}}()

    for folder in folders
        index = 1
        label = parse_label(folder)
        map_dir = get_directories(folder, subdirectory = subdirectory * "/")[3]
        files = get_all_files(map_dir, true)  
        if haskey(doppler_frames, label)
            index = length(doppler_frames[label]) + 1
            resize!(doppler_frames[label], length(doppler_frames[label]) + length(files))
        else
            doppler_frames[label] = Vector{Vector{AbstractMatrix}}(undef, length(files))
        end
        for file in files
            doppler_frames[label][index] =  load(file)["Doppler FFT Frames"] 
            index += 1
        end
    end

    return doppler_frames

end

# Prepare the data for the Flux loaders.
# Optionally seperates the I and Q samples from the Complex samples.
function prepare_for_flux(classes_data::Dict{String, Vector{Vector{AbstractMatrix}}}; seperate_channels = true)

    # Get meta data.
    image_size = size(first(classes_data)[2][1][1])
    frame_count = length(first(classes_data)[2][1])
    if seperate_channels 
        frame_count *= 2 
    end

    # Calculate total samples.
    total_samples = 0
    for (_, samples) in classes_data
        total_samples += length(samples)
    end

    # Prep new memory.
    samples_flux = Array{Float64, 5}(undef, image_size[1], image_size[2], frame_count, 1, total_samples)
    labels = Array{Int}(undef, total_samples)

    arr_sample = 0
    for (label, samples) in classes_data
        for (_, sample) in enumerate(samples)
            arr_sample += 1
            for (f, frame) in enumerate(sample)
                if seperate_channels
                    samples_flux[:,:,f*2-1,1,arr_sample] = real(frame)
                    samples_flux[:,:,f*2,1,arr_sample] = imag(frame)
                else
                    samples_flux[:,:,f,1,arr_sample] = abs(frame)
                end
                labels[arr_sample] = get_one_hot_index(label)
            end
        end
    end

    return samples_flux, labels

end

# Use the Flux data loaders.
function flux_load(classes_data::Array{Float64, 5}, labels, args::Args; shuffle = false)
    y = onehotbatch(labels, 1:length(get_labels()))
    return DataLoader((classes_data, y), batchsize = args.batchsize, shuffle = shuffle) 
end

# Get the index related to the label.
function get_one_hot_index(label)
    label = parse_label(label)
    for (i, l) in enumerate(get_labels())
        if l == label return i end
    end
    @assert false "Invalid label."
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
    classes = length(get_elevated_folder_list())
    train_y = onehotbatch(train_y, 1:classes)
    test_y = onehotbatch(test_y, 1:classes)
    return train_x, train_y, test_x, test_y

end

function get_2persons_loaders(args::Args)

    # Metadata.
    steph_folders = get_elevated_folder_list()
    janke_folders = get_janke_folder_list()
    labels = get_labels()

    # Get data in a nicer format and combined classes.
    # Output format: 
    # Dict { 
    #   Label::String, 
    #   Samples::Vector{Vector{AbstractMatrix}}
    #            (Samples,Frames,Frame)
    # }
    steph_classes = load_classes_from_folders(steph_folders, args.frames_folder)
    janke_classes = load_classes_from_folders(janke_folders, args.frames_folder) 

    # Convert to  format that the Flux loaders can use.
    # Sets up the IQ samples as well.
    steph_classes, steph_labels = prepare_for_flux(steph_classes)
    janke_classes, janke_labels = prepare_for_flux(janke_classes)

    # Load the data for Flux.
    train = flux_load(steph_classes, steph_labels, args, shuffle = true)
    test = flux_load(janke_classes, janke_labels, args)

    return train, test, labels

end

function flux_load_split(classes_data::Array{Float64, 5}, labels, args::Args; shuffle = false)
    split_idx = floor(Int, args.split*size(classes_data, 5))
    train_x, test_x = classes_data[:,:,:,:,1:split_idx], classes_data[:,:,:,:,split_idx+1:end]
    train_labels, test_labels  = labels[1:split_idx], labels[split_idx+1:end]
    train_y = onehotbatch(train_labels, 1:length(get_labels()))
    test_y = onehotbatch(test_labels, 1:length(get_labels()))
    train_dl = DataLoader((train_x, train_y), batchsize = args.batchsize, shuffle = shuffle) 
    test_dl = DataLoader((test_x, test_y), batchsize = args.batchsize) 
    return train_dl, test_dl
end

function get_1person_loaders(args::Args)

    # Metadata.
    steph_folders = get_elevated_folder_list()
    labels = get_labels()

    # Get data in a nicer format and combined classes.
    # Output format: 
    # Dict { 
    #   Label::String, 
    #   Samples::Vector{Vector{AbstractMatrix}}
    #            (Samples,Frames,Frame)
    # }
    steph_classes = load_classes_from_folders(steph_folders, args.frames_folder)

    # Convert to  format that the Flux loaders can use.
    # Sets up the IQ samples as well.
    steph_classes, steph_labels = prepare_for_flux(steph_classes)

    # Load the data for Flux.
    train, test = flux_load_split(steph_classes, steph_labels, args, shuffle = true)

    return train, test, labels

end

# Load the data from the jdl files and prepare them for training.
# Preparation includes using `Flux.DataLoader()`.
function get_data_loaders(args::Args)
    @info "Preparing data..."
    if args.persons == 2 
        return get_2persons_loaders(args)
    elseif  args.persons == 1
        return get_1person_loaders(args)
    end
    @assert false "Invalid persons argument!"
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
