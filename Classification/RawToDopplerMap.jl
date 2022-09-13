include("DopplerMap.jl")

# Meta data.
folder 			= "Test"
files_to_load = [
    "004",
    "005",
    "006",
    "007",
    "008",
    "009",
    "010",
    "011",
    "012"
]

files_to_load = [ "012" ]

# Fixed data.
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"

# Load all of the files.
Base.Threads.@threads for file_number in files_to_load

    # Create file.
    file = path * folder * file_prefix * file_number
    
    # Calculate doppler data.
    doppler_fft_matrix, distance_vector, velocity_vector = calculate_doppler_map(abspath(file))
    
    # Destination file.                                                    
    destination_folder = "Data/EntireDopplerMap/" * folder * "/"
    destination_file = relpath(destination_folder * file_prefix * file_number * ".jld")
    
    # Save the data to file.
    meta_data = load_meta_data(file * ".txt")
    save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                           "Velocity", velocity_vector,
                           "Distance", distance_vector,
                           "Meta Data", meta_data)

    # plot(doppler_fft_matrix, distance_vector, velocity_vector)

end
