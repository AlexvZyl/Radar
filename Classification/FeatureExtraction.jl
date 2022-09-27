# Modules.
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")

# Remove the distance and velocity means from the matrix.
function normalise!(matrix_vector::Vector{AbstractMatrix})
    max = maximum(maximum.(matrix_vector))
    for (i, matrix) in enumerate(matrix_vector)
        for (r, row) in enumerate(eachrow(matrix))
            for (c, col) in enumerate(row)
                matrix[r, c] /= max
            end
        end
    end
end

# Extract the features from the doppler frames stored in the file.
function extract_features(folder::String, files_to_load::Vector{String} = [])
    
    print("Extracting features...")

    # Get filesystem data.
    map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)

    # Get all of the files in the directory.
    load_all_files = length(files_to_load) == 0
    if load_all_files 
        files_to_load = readdir(extracted_targets_dir)
    # Convert the file numbers into files.
    else
        files_to_load = get_files(folder, files_to_load)
    end
    
    # Iterate over the files.
    Base.Threads.@threads for file in files_to_load
    
        # Load data.
        target_frame_data = load(extracted_targets_dir * file)
        target_frames = target_frame_data["Target Frames"]
    
        # Get absolute value.
        for (i, frame) in enumerate(target_frames) 
            target_frames[i] = abs.(target_frames[i])
        end
    
        # Need to normalise the doppler values since the classifier has to be able to detect targets 
        # at different ranges.  Targets at longer distances have smaller magnitudes.
        # I wonder if the higher noise at longer distances will confuse the classifier... Using a
        # NN would really be better.
        normalise!(target_frames)

        # Append the target frames (rows) to the feature vector.
        feature_vector = Vector{Float64}(undef, 0)
        for frame in target_frames
            for row in eachrow(frame)
                append!(feature_vector, row)
            end
        end
    
        # Save the features.
        save(features_dir * file, "Feature Vector", feature_vector)
    
        # Debugging.
        target_distance = target_frame_data["Target Distance"]
        target_velocity = target_frame_data["Target Velocity"]
        snr_threshold = 0
        animate(target_frames, target_distance, target_velocity, snr_threshold = 0, snr_max = 1, use_db = false)
    
    end

    println(" Done.")

end
