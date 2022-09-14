# Takes the doppler frames and clustering information and extracts the relevant targets.
# This requires a user to provdide input.

# Modules.
include("DopplerMap.jl")
include("Directories.jl")
using JLD
using Base.Threads

# Functions that parses the input from the user.
function parse_cluster_input(input::String)
    parsed_input = Vector{String}(undef, 0)
    push!(parsed_input, string(""))
    for c in input
        # Add character if not a space.
        if c != ' '
             parsed_input[end] = parsed_input[end] * c 
        # If it is a space, start a new string.
        else
            push!(parsed_input, string(""))
        end
    end
    parsed_input
end

# File data.
folder = "Test"
map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)
all_files = false
# If all files is not true we have to use specific files.
selected_files = [
    "010"
    "011"
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

# Allow the user to input which cluster contains the target.
tb = Textbox(figure[2,1], placeholder = "Enter the cluster containing the target. Seperate with spaces for multiple clusters.", tellwidth = false)

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
        poly_size = [ 8, 0.13 ] 
        poly_vertices = Point2f[
            ( position[1] - poly_size[1], position[2] - poly_size[2] ),
            ( position[1] + poly_size[1], position[2] - poly_size[2] ),
            ( position[1] + poly_size[1], position[2] + poly_size[2] ),
            ( position[1] - poly_size[1], position[2] + poly_size[2] ),
        ]
        scatter!(distance_data, velocity_data)
        poly!(poly_vertices, color = (:black, 0.7))
        text!(position[1], position[2], text = string(i), textsize = 20, align = (:center, :center))
    end

    # Data required for the input loop.
    keep_asking = true
    condition = Threads.Condition()

    # Add a callback the notifies the condition of a change. 
    on(tb.stored_string) do s
        lock(condition)
        notify(condition, s)
        unlock(condition)
    end

    # Loop until the user inputs valid data.
    while keep_asking

        # Wait for the user to input the values.
        lock(condition)
        input_string = wait(condition)
        unlock(condition)
        
        # Parse the input.
        parsed_input = parse_cluster_input(input_string)
        println(parsed_input)

        # Validate the input.
        try 
            parsed_input = parse.(Int, parsed_input)
            println(parsed_input)
            keep_asking = false
        # If input is invalid, keep asking.
        catch
            keep_asking = true
        end

        # Now save the cluster label.
        if keep_asking == false
            save(get_file_path(labels_dir, file),
                 "Target Labels", parsed_input)                        
        end
 
    end

end
