include("DopplerMap.jl")

# Meta data.
folder 			= "Test"
file_number 	= "012"
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number

# Calculate doppler data.
doppler_fft_matrix, distance_vector, velocity_vector = calculate_doppler_map(abspath(file))

# Destination file.                                                    
destination_folder = "Data/EntireDopplerMap/" * folder * "/"
destination_file = relpath(destination_folder * file_prefix * file_number * ".jld")

# Save the data to file.
save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                       "Velocity", velocity_vector,
                       "Distance", distance_vector)

