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
