using Clustering
using JLD 

# Calculate the distance of the point for DBSCAN.
function calculate_distance(value::Complex)
    return abs(value)
end

# Plot the DBSCAN result.
function plot(result::DBSCAN)

end

# Meta data.
folder = "Test"
file_number = "012"

# Load the data.
file = "Data/" * folder * "/B210_SAMPLES_" * folder * "_" * file_number * ".jld"
doppler_fft_matrix = load(file)["Doppler FFT Matrix"]

# Calculate a distance matrix from the complex data.
distance_matrix = calculate_distance.(doppler_fft_matrix)

# Implement DBSCAN. 
result = dbscan(distance_matrix, 0.5)
display(result)


