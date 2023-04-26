include("../Utilities/MakieGL/MakieGL.jl")
include("Utilities.jl")
using Statistics
using JLD2

update_theme!(
    Axis = (
        yticklabelpad = 20,
	    ylabelpadding = 30,
        xlabelpadding = 20,
	    xtickwidth = 3,
	    ytickwidth = 3,
	    xticksize = 24,
	    yticksize = 24,
	    xtickalign = 0,
	    ytickalign = 1,
	    spinewidth = 3,
	    titlegap = 40
    ),
	figure_padding = (10, 50, 10, 10)
)

function clustered_map(folder::String, file::String, title::String, save_name::String)

    # Create the figure and axis. 
    figure = Figure(resolution=(1920,1080))
    Axis(figure[1,1], title = title, xlabel = "Distance (m)", ylabel = "Velocity (m/s)")

    map_dir, cluster_dir, _, _, _, _ = get_directories(folder)
        
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
        scatter!(distance_data, velocity_data)
    end

    save(save_name, figure)

end

# Ground.
ground_file_number = "000"
ground_folder = "WalkingTowards"
ground_file = get_file_name(ground_folder, ground_file_number)
ground_file_save = "MP_CLUSTERING_GROUND.pdf"
clustered_map(ground_folder, ground_file, "Clustering at Ground Level", ground_file_save)

# Elevated.
elevated_file_number = "002"
elevated_folder = "WalkingTowards_Elevated_90deg"
elevated_file = get_file_name(elevated_folder, elevated_file_number)
elevated_file_save = "MP_CLUSTERING_ELEVATED.pdf"
clustered_map(elevated_folder, elevated_file, "Clustering at an Elevated Level", elevated_file_save)
