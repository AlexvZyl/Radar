# Takes the doppler frames and clustering information and extracts the relevant targets.
# This requires a user to provdide input.

# Modules.
include("DopplerMap.jl")
include("Directories.jl")
using JLD
using Base.Threads

# File data.
folder = "Test"
map_dir, cluster_dir, frames_dir = get_directories(folder)
all_files = false
# If all files is not true we have to use specific files.
selected_files = [
    "012"
]

# Get all of the files in the directory.
if all_files
    selected_files = readdir(cluster_dir)
else
# Load the files specified.
    for (i, number) in enumerate(selected_files)
        selected_files[i] = get_file_name(folder, number)
    end
end

# Create the figure and axis. 
figure = Figure()
Axis(figure[1,1])
display(figure)

# The user now has to identify the cluster that has the target for each doppler map.
for file in selected_files
    
    # Load the data.
    cluster_file_data = load(cluster_dir * file)
    doppler_file_data = load(map_dir * file)
   
    # Load the data.
    adjacency_matrix = cluster_file_data["Adjacency Matrix"]
    doppler_fft_matrix = doppler_file_data["Doppler FFT Matrix"]
    distance = doppler_file_data["Distance"]
    velocity = doppler_file_data["Velocity"]
    snr_threshold = 0
    result = cluster_file_data["Clustering Result"]

    # Plot the doppler data with the cluster.
    heatmap!(figure[1, 1], distance, velocity, 20*log10.(abs.(doppler_fft_matrix)), colorrange = [snr_threshold, 20])

    # Plot the cluster labels.
    for (i, cluster) in enumerate(result)
        # init data.
        distance_data = Array{Float32}(undef, cluster.size)
        velocity_data = Array{Float32}(undef, cluster.size)
        # populate data.
        for (i, index) in enumerate(cluster.core_indices)
            distance_data[i] = adjacency_matrix[1, index] 
            velocity_data[i] = adjacency_matrix[2, index] 
        end
        for (i, index) in enumerate(cluster.boundary_indices)
            distance_data[i] = adjacency_matrix[1, index] 
            velocity_data[i] = adjacency_matrix[2, index] 
        end
        position = [ mean(distance_data), mean(velocity_data) ]    
        poly_size = [ 10, 0.2 ] 
        poly_vertices = Point2f[
            ( position[1] - poly_size[1], position[2] - poly_size[2] ),
            ( position[1] + poly_size[1], position[2] - poly_size[2] ),
            ( position[1] + poly_size[1], position[2] + poly_size[2] ),
            ( position[1] - poly_size[1], position[2] + poly_size[2] ),
        ]
        scatter!(distance_data, velocity_data)
        poly!(poly_vertices, color = (:black, 0.7))
        text!(position[1], position[2], text = string(i), textsize = 30, align = (:center, :center))
    end

    # Allow the user to input which cluster contains the target.
    tb = Textbox(figure[2,1], placeholder = "Enter the cluster containing the target. Seperate with spaces for multiple clusters.", tellwidth = false)

    # Read the string when enter is pressed.
    on(tb.stored_string) do s
        println(s)
    end

end
