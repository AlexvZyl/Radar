# Modules.
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")

# Convert the velocity samples so that it can be used to index the doppler map.
function relative_to_absolute_velocity_sample(sample::Number, total_samples::Number)
    return Int(  sample + (total_samples / 2) )
end

# Extract the target doppler map from the larger doppler map.
function extract_target(doppler_fft_matrix::AbstractMatrix, clusters::Vector{DbscanCluster}, labels::Vector{Int}, 
                        adjacency_matrix::AbstractMatrix, distance_range::AbstractRange, velocity_range::AbstractRange)

    # The target cluster has to be extracted from the larger Doppler map.
    # I am unsure how this should be done exactly, but for now lets extract it
    # as a rectangular matrix.    
    target_clusters = clusters[labels] 
    distance_data, velocity_data = adjacency_to_doppler(adjacency_matrix, target_clusters)

    # Find the limits of the selected blob.
    distance_limits = [ minimum(distance_data), maximum(distance_data) ]
    velocity_limits = [ minimum(velocity_data), maximum(velocity_data) ]

    # Find the indices for the doppler map.
    distance_resolution = step(distance_range)
    velocity_resolution = step(velocity_range)
    distance_indices = floor.(Int, distance_limits ./ distance_resolution) .+1
    velocity_indices = floor.(Int, velocity_limits  ./ velocity_resolution)
    velocity_indices = relative_to_absolute_velocity_sample.(velocity_indices, length(velocity_range))
    sort!(velocity_indices)

    # Get the range data for the target.
    target_distance = distance_limits[1]:distance_resolution:distance_limits[2]
    target_velocity = velocity_limits[1]:velocity_resolution:velocity_limits[2]
    
    # Extract the target and return it.
    target_map = doppler_fft_matrix[range(distance_indices[1], distance_indices[2]), range(velocity_indices[1], velocity_indices[2])]
    return target_map, target_distance, target_velocity

end

# The folder from where the data will be loaded.
folder = "Test"

# Get filesystem data.
map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)
# files = get_all_files(map_dir)
files = get_files(folder, [ "012" ])

# Other parameters.
snr_threshold = 0

# Go through all of the files.
Base.Threads.@threads for file in files
    
    # Load the data.
    cluster_file_data = load(cluster_dir * file)
    doppler_file_data = load(map_dir * file)   
    doppler_frames_data = load(frames_dir * file)
    doppler_frames = doppler_frames_data["Doppler FFT Frames"]
    adjacency_matrix = cluster_file_data["Adjacency Matrix"]
    distance = doppler_file_data["Distance"]
    velocity = doppler_file_data["Velocity"]
    clusters = cluster_file_data["Clustering Result"]
    labels = load(labels_dir * file)["Target Labels"]

    # Extract the target from each frame.
    target_frames = Vector{AbstractMatrix}(undef, length(doppler_frames))
    null, target_distance, target_velocity = extract_target(doppler_frames[1], clusters, labels, adjacency_matrix, distance, velocity)
    for (i, frame) in enumerate(doppler_frames)
        target_frames[i], null1, null2 = extract_target(frame, clusters, labels, adjacency_matrix, distance, velocity)
    end

    # Save the information.
    save(get_file_path(extracted_targets_dir, file),
         "Target Frames", target_frames,
         "Target Distance", target_distance,
         "Target Velocity", target_velocity)

    animate(target_frames, target_distance, target_velocity, snr_threshold = 0)
  
end
