include("DopplerMap.jl")

# Meta data.
folder 			= "Test"
file_number 	= "012"
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number

# Calculate doppler data.
doppler_fft_matrix, distance_vector, velocity_vector = calculate_doppler_map(file)

# Destination file.                                                    
destination_folder = "Data/" * folder * "/"
destination_file = destination_folder * file * ".jld"  

# Save the data to file.
save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                       "Velocity", velocity_vector,
                       "Distance", distance_vector)

# Debug with plot.
figure = Figure()
axis = Axis(figure[1,1])
doppler_fft_matrix = 20*log10.(abs.(doppler_fft_matrix))
hm = heatmap!(figure[1, 1], distance_vector, velocity_vector, doppler_fft_matrix, colorrange = [15, 20])
display(figure)
