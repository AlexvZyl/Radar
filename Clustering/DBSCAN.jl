include("../Utilities/MakieGL/PlotUtilities.jl")
using Clustering
using JLD 

# Weights for the DBSCAN parameters.
struct WeightParameters
    distance
    velocity
    real
    imag
end 
global weight_parameters = WeightParameters(2, 2, 1, 1)

# Create a d*n adjacency matrix to.
function create_adjacency_matrix(doppler_data::Matrix{ComplexF64}, distance::AbstractRange, velocity::AbstractRange; snr_threshold::Number = 15)

    total_entries = size(doppler_data, 1) * size(doppler_data, 2)
    distance_step = step(distance)
    # The 4 dimensions: distance, velocity, real, imagenary.
    adjacency_matrix = Matrix{Float32}(undef, 4, 0)
    # Calculate the DB value to compare to the threshold.
    doppler_data_db = 20*log10.(abs.(doppler_data))   
    # Calculate the matrix column major.
    for c in 1:size(doppler_data_db, 2)
        for r in 1:size(doppler_data_db, 1)
            # We can ignore values that are not detected by the radar.
            if doppler_data_db[r, c] >= snr_threshold
                new_entry = [ ((distance_step*r)-distance_step/2) * weight_parameters.distance, 
                              velocity[c] * weight_parameters.velocity, 
                              real(doppler_data[r, c]) * weight_parameters.real,  
                              imag(doppler_data[r, c]) * weight_parameters.imag ]
                adjacency_matrix = hcat(adjacency_matrix, new_entry)
            end
        end
    end

    return adjacency_matrix
end

# Plot the DBSCAN result.
function plot(result::Vector{DbscanCluster}, adjacency_matrix::AbstractMatrix, doppler_data::Matrix{ComplexF64}, distance::AbstractRange, velocity::AbstractRange; snr_threshold::Number = 15)
    # Setup,
    figure = Figure()
    axis = Axis(figure[1,1])

    # Plot doppler data.
    doppler_data_db = 20*log10.(abs.(doppler_data))
    hm = heatmap!(figure[1, 1], distance, velocity, doppler_data_db, colorrange = [snr_threshold, 20])

    # Plot the dbsan results.
    for cluster in result
        # Init data.
        distance_data = Array{Float32}(undef, cluster.size)
        velocity_data = Array{Float32}(undef, cluster.size)
        # Populate data.
        for (i, index) in enumerate(cluster.core_indices)
            distance_data[i] = adjacency_matrix[1, index] / weight_parameters.distance
            velocity_data[i] = adjacency_matrix[2, index] / weight_parameters.velocity
        end
        for (i, index) in enumerate(cluster.boundary_indices)
            distance_data[i] = adjacency_matrix[1, index] / weight_parameters.distance
            velocity_data[i] = adjacency_matrix[2, index] / weight_parameters.velocity
        end 
        scatter!(distance_data, velocity_data)
    end

    # Display to screen.
    display(figure)    
end

# Meta data.
folder = "Test"
file_number = "012"

# Load the data.
file = "Data/" * folder * "/B210_SAMPLES_" * folder * "_" * file_number * ".jld"
file_data = load(file)
doppler_fft_matrix = file_data["Doppler FFT Matrix"]
distance = file_data["Distance"]
velocity = file_data["Velocity"]

# DBSCAN.
adjacency_matrix = create_adjacency_matrix(doppler_fft_matrix, distance, velocity)
result = dbscan(adjacency_matrix, 10, min_cluster_size = 5)

# Plot.
plot(result, adjacency_matrix, doppler_fft_matrix, distance, velocity)
