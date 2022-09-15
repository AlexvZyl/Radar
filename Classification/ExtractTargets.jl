# Modules.
include("Directories.jl")
include("Utilities.jl")

# The folder from where the data will be loaded.
folder = "Test"

# Get filesystem data.
map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)
# files = get_all_files(map_dir)
files = get_files(folder, [ "012" ])

# Go through all of the files.
Base.Threads.@threads for file in files
    
    # Load the data.
    cluster_file_data = load(cluster_dir * file)
    doppler_file_data = load(map_dir * file)   
    adjacency_matrix = cluster_file_data["Adjacency Matrix"]
    doppler_fft_matrix = doppler_file_data["Doppler FFT Matrix"]
    distance = doppler_file_data["Distance"]
    velocity = doppler_file_data["Velocity"]
    clusters = cluster_file_data["Clustering Result"]
    labels = load(labels_dir * file)["Target Labels"]

    # The target cluster has to be extracted from the larger Doppler map.
    # I am unsure how this should be done exactly, but for now lets extract it
    # as a rectangular matrix.    
    target_clusters = clusters[labels] 
    distance_data, velocity_data = adjacency_to_doppler(adjacency_matrix, target_clusters)

    # Find the limits of the selected blob.
    distance_limits = [ minimum(distance_data), maximum(distance_data) ]
    velocity_limits = [ minimum(velocity_data), maximum(velocity_data) ]

    # Find the indices for the doppler map.
    distance_resolution = step(distance)
    velocity_resolution = step(velocity)
    distance_indices = floor.(Int, distance_limits ./ distance_resolution)
    velocity_indices = floor.(Int, velocity_limits ./ velocity_resolution)
    # Offset the velocity indices since we need to use them to index into the matrix.
    velocity_indices .+= length(velocity)
    
    # Extract the target and save it.
    target_map = doppler_fft_matrix[range(distance_indices[1], distance_indices[2]), range(velocity_indices[1], velocity_indices[2])]
    save(get_file_path(extracted_targets_dir, file),
        "Target Map", target_map)
  
end
