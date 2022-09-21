# Modules.
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")
import Images

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

# The size used for the features.
# Some images will have to be upscaled to fit (or downscaled).
const image_base_size = (25, 25)

function extract_features(folder::String, files_to_load::Vector{String} = [])
    
    print("Extracting features...")

    # Get filesystem data.
    map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)

    # Get all of the files in the directory.
    load_all_files = length(files_to_load) == 0
    if load_all_files 
        files_to_load = readdir(map_dir)
    # Convert the file numbers into files.
    else
        files_to_load = get_files(folder, files_to_load)
    end
    
    # Other parameters.
    snr_threshold = 0
    
    # Iterate over the files.
    Base.Threads.@threads for file in files_to_load
    
        # Load data.
        target_frame_data = load(extracted_targets_dir * file)
        target_frames = target_frame_data["Target Frames"]
        target_distance = target_frame_data["Target Distance"]
        target_velocity = target_frame_data["Target Velocity"]
    
        # Get absolute value.
        for (i, frame) in enumerate(target_frames) 
            target_frames[i] = abs.(frame)
        end
    
        # Need to normalise the doppler values since the classifier has to be able to detect targets 
        # at different ranges.  Targets at longer distances have smaller magnitudes.
        # I wonder if the higher noise at longer distances will confuse the classifier... Using a
        # NN would really be better.
        normalise!(target_frames)
        
        # If one of the dimensions of the image is of size one it cant be upsampled.
        # This should not happen in any case, so these files can just be discarded.
        try 
    
            # Init.
            feature_vector = Vector{Float64}(undef, 0)
    
            # Need to resize the image to fit the base.
            for (i, frame) in enumerate(target_frames)
                target_frames[i] = Images.imresize(frame, image_base_size) 
            end
    
            # Append the target frames to the feature vector.
            for frame in target_frames
                for row in eachrow(frame)
                    append!(feature_vector, row)
                end
            end
    
            # Save the features.
            save(features_dir * file, "Feature Vector", feature_vector)
    
        # Could not resize the image.
        catch
            print(" Could not resize image: " * file * "...")
        end
    
        # Debugging.
        # animate(target_frames, target_distance, target_velocity, snr_threshold = 0, snr_max = 1, use_db = false)
    
    end

    println(" Done.")

end
