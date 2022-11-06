using Clustering
using JLD 

# Create a d*n adjacency matrix to.
function create_adjacency_matrix(doppler_data::Matrix{ComplexF64}, distance::AbstractRange, velocity::AbstractRange; snr_threshold::Number = 15)

    # Setup data.
    distance_step = step(distance)
    adjacency_matrix = Matrix{Float32}(undef, 3, 0)
    doppler_data_db = amp2db.(abs.(doppler_data))   
    # Calculate the matrix column major.
    for c in 1:Base.size(doppler_data_db, 2)
        for r in 1:Base.size(doppler_data_db, 1)
            # We can ignore values that are not detected by the radar.
            if doppler_data_db[r, c] >= snr_threshold
                new_entry = [ ((distance_step*r)-distance_step/2) * weight_parameters.distance, 
                              velocity[c] * weight_parameters.velocity, 
                              doppler_data_db[r, c] * weight_parameters.magnitude ]  
                adjacency_matrix = hcat(adjacency_matrix, new_entry)
            end
        end
    end

    return adjacency_matrix
end

# Convert the adjacency matrix and cluster result to doppler map data.
function adjacency_to_doppler(adjacency_matrix::AbstractMatrix, cluster::DbscanCluster)
    # Init data.
    distance_data = Array{Float32}(undef, cluster.size)
    velocity_data = Array{Float32}(undef, cluster.size)
    # Populate data.
    for (i, index) in enumerate(cluster.core_indices)
        distance_data[i] = adjacency_matrix[1, index] 
        velocity_data[i] = adjacency_matrix[2, index] 
    end
    for (i, index) in enumerate(cluster.boundary_indices)
        distance_data[i] = adjacency_matrix[1, index] 
        velocity_data[i] = adjacency_matrix[2, index] 
    end 
    return distance_data, velocity_data
end

# Convert a vector of clusters into the relevant Doppler data.
function adjacency_to_doppler(adjacency_matrix::AbstractMatrix, clusters::Vector{DbscanCluster})
    # Init data.
    total_distance_data = Array{Float32}(undef, 0)
    total_velocity_data = Array{Float32}(undef, 0)
    for cluster in clusters
        distance_data, velocity_data = adjacency_to_doppler(adjacency_matrix, cluster)        
        total_distance_data = append!(total_distance_data, distance_data)
        total_velocity_data = append!(total_velocity_data, velocity_data)
    end
    return total_distance_data, total_velocity_data
end

# Load the features as an observation matrix.
function load_observation_matrix(folder::String)

    features_dir = get_directories(folder)[5]
    files = get_all_files(features_dir, true)
    
    # Get the amount of features.
    feature_count = length(load(files[1])["Feature Vector"])
    
    # Load the features from the files and put them in a matrix.
    # (Each column is an observation)
    observation_matrix = Matrix{Float64}(undef, feature_count, 0)
    for file in files
        feature_vector = load(file)["Feature Vector"]
        observation_matrix = hcat(observation_matrix, feature_vector)
    end

    return observation_matrix

end

# Convert a vector into a vector of vectors to limit the amount of instances Julia's
# multithreading can use.
function vectorise(data::AbstractVector; size = 2)
    vectorised_data = Vector{typeof(data)}(undef, 0)
    for (i, entry) in enumerate(data)
        if( (i-1) % size == 0 ) 
            push!(vectorised_data, typeof(data)(undef, 0))
        end
        push!(vectorised_data[ceil(Int, i/size)], entry)    
    end   
    return vectorised_data
end

# Randomly remove the amount of data requested and return it.
function random_delete(data::AbstractMatrix; ratio = 0.3, dimension = 2)

    # Calculate the amount to delte.
    to_delete = floor(Int, Base.size(data)[dimension] * ratio)

    # Delete the amount.
    for _ in 1:to_delete
        random_index = rand(1:Base.size(data)[dimension])
        data = data[:, 1:end .!= random_index]
    end

    # Return the deleted amount.
    return data

end

# Get the paths of the directories to be used for the data.
# These directories are used by a few files and this makes it easier to work with.
function get_directories(folder::String; subdirectory = "")
    parent_dir = "/home/alex/GitHub/Radar/Classification/Data/" .. subdirectory
    cluster_dir = parent_dir * "DopplerClustering/" * folder * "/"
    frames_dir = parent_dir * "DopplerFrames/" * folder * "/"
    map_dir = parent_dir * "EntireDopplerMap/" * folder * "/"
    labels_dir = parent_dir * "ClusterLabels/" * folder * "/"
    features_dir = parent_dir * "Features/" * folder * "/"
    targets_dir = parent_dir * "ExtractedTargets/" * folder * "/"
    map_dir, cluster_dir, frames_dir, labels_dir, features_dir, targets_dir
end

# Create a file name including the path.
function get_file_path(dir::String, file::String)
    dir * file 
end

# Craete the file name without a path.
function get_file_name(folder::String, number::String; extension::String = ".jld")
    "B210_SAMPLES_" * folder * "_" * number * extension
end

# Get all of the files contained in the folder.
function get_all_files(path::String, append_to_path = false)
    files = readdir(path)
    if append_to_path
        return path .* files
    end
    files
end

# Create the files based on the numbers and folder.
function get_files(folder::String, file_numbers::Vector{String})
    get_file_name.(folder, file_numbers)
end

# Remove the extension from the filename.
function remove_extension(file::String)
    splitext(file)[1]
end

# Get a list of the names of the elevated folders.
function get_elevated_folder_list()
    return String[
        "WalkingAway_Elevated_90deg",
        # "WalkingAway_Elevated_90deg_Stick",
        "WalkingTowards_Elevated_90deg",
        # "WalkingTowards_Elevated_90deg_Stick",
        "JoggingAway_Elevated_90deg",
        "JoggingAway_Elevated_90deg_Stick",
        "JoggingTowards_Elevated_90deg",
        "JoggingTowards_Elevated_90deg_Stick",
        # "Clutter"
    ]
end
