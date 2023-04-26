include("../Utilities/MakieGL/MakieGL.jl")
using Statistics
using JLD2

function clustered_map(file::String, title::String, save_name::String)

    # Create the figure and axis. 
    figure = Figure()
    Axis(figure[1,1], title = title, xlabel = "Distance (m)", ylabel = "Velocity (m/s)")
        
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

    save(save_name, figure)

end

# Ground.
ground_file_number = "000"
ground_folder = "WalkingTowards"
ground_file = get_file_name(ground_folder, ground_file_number)
ground_file_save = "MP_CLUSTERING_GROUND.pdf"
clustered_map(ground_file, "Ground Level", ground_file_save)

# Elevated.
elevated_file_number = "000"
elevated_folder = "Walking_Away_Aleza"
elevated_file = get_file_name(elevated_folder, elevated_file_number)
elevated_file_save = "MP_CLUSTERING_ELEVATED.pdf"
clustered_map(elevated_file, "Ground Level", elevated_file_save)
