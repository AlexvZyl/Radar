include("../Utilities/MakieGL/PlotUtilities.jl")
using Clustering
using JLD 

# Weights for the DBSCAN parameters.
struct WeightParameters
    distance
    velocity
    magnitude
end 
global weight_parameters = WeightParameters(1/1000 * 10, 1/10 * 10, 1/20 * 0.5)

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

# Plot the DBSCAN result.
function plot(result::Vector{DbscanCluster}, adjacency_matrix::AbstractMatrix, doppler_data::Matrix{ComplexF64}, distance::AbstractRange, velocity::AbstractRange; snr_threshold::Number = 15)

    # Setup.
    figure = Figure()
    Axis(figure[1,1])

    # Plot doppler data.
    doppler_data_db = 20*log10.(abs.(doppler_data))
    heatmap!(figure[1, 1], distance, velocity, doppler_data_db, colorrange = [snr_threshold, 20])

    # Plot the dbsan results.
    for cluster in result
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
        scatter!(distance_data, velocity_data)
    end

    # Display to screen.
    display(figure)    
end

# Parameters.
snr_threshold = 12
dbscan_radius = 0.18
min_cluster_size = 5
min_neighbors = 1
leaf_size = 20

# Meta data.
folder = "Test"
file_number = "012"

# Load the data.
file_prefix =  "/B210_SAMPLES_" * folder * "_"
file = "Data/EntireDopplerMap/" * folder * file_prefix * file_number * ".jld"
file_data = load(file)
doppler_fft_matrix = file_data["Doppler FFT Matrix"]
distance = file_data["Distance"]
velocity = file_data["Velocity"]

# DBSCAN.
adjacency_matrix = create_adjacency_matrix(doppler_fft_matrix, distance, velocity, snr_threshold = snr_threshold)
result = dbscan(adjacency_matrix, dbscan_radius, min_cluster_size = min_cluster_size, min_neighbors = min_neighbors, leafsize = leaf_size)

# Correct the distance and velocity data before using.
display(adjacency_matrix)
for c in range(1, Base.size(adjacency_matrix, 2))
    adjacency_matrix[1,c] /= weight_parameters.distance
    adjacency_matrix[2,c] /= weight_parameters.velocity
end

# Plot.
plot(result, adjacency_matrix, doppler_fft_matrix, distance, velocity, snr_threshold = snr_threshold)

# Destination file.                                                    
destination_folder = "Data/DopplerClustering/" * folder * "/"
destination_file = destination_folder * file_prefix * file_number * ".jld"  

# Save the data to file.
save(destination_file, 
    "Clustering Result", result,
    "Adjacency Matrix", adjacency_matrix,
    "Weight Parameters", weight_parameters)
