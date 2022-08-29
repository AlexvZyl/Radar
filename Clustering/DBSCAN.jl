using Clustering
using JLD 

# Create a d*n adjacency matrix to.
function create_adjacency_matrix(doppler_data::AbstractMatrix, range_step::Number, velocity_step::Number)
    total_entries = shape(doppler_data, 1) * shape(doppler_data, 1)
    # The 4 dimensions are: distance, velocity, real, imagenary.
    adjacency_matrix = Matrix{Float32}(undef, 4, total_entries)

end

# Plot the DBSCAN result.
function plot(result::DbscanResult)
     
end

# Meta data.
folder = "Test"
file_number = "012"

# Load the data.
file = "Data/" * folder * "/B210_SAMPLES_" * folder * "_" * file_number * ".jld"
file_data = load(file)
doppler_fft_matrix = file_data["Doppler FFT Matrix"]
range_step = step(file_data["Range"])
velocity_step = step(file_data["Velocity"])

# DBSCAN.
adjacency_matrix = create_adjacency_matrix(doppler_fft_matrix, range_step, velocity_step)
result = dbscan(distance_matrix, 0.5, 4)
display(result)
