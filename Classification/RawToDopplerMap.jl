include("DopplerMap.jl")
include("Directories.jl")

function raw_to_doppler_map(folder::String, files_to_load::Vector{String} = [])

    print("Processing raw data into doppler maps...")

    # Location of the data collected by the SDR.
    path = "/home/alex/GitHub/SDR-Interface/build/Data/" * folder * "/"

    # Load the required files (without path).
    # If no files are specified load the entire directory.
    if length(files_to_load) == 0
        files_to_load = get_all_files(path)
    else
        files_to_load = get_files(folder, files_to_load)
    end

    # Filter the files.
    filter!(f -> splitext(f)[2] == ".bin", files_to_load)
    filter!(f -> !occursin("Phase", f), files_to_load)
    
    # Get the doppler map from each raw file.
    Base.Threads.@threads for file in files_to_load
        
        # The doppler map function takes a file with no extension (very inconsistent API writing on my part).
        file = remove_extension(file)

        # Calculate doppler data.
        doppler_fft_matrix, distance_vector, velocity_vector = calculate_doppler_map(path * file)
        
        # Destination file.                                                    
        destination_folder = "Data/EntireDopplerMap/" * folder * "/"
        destination_file = relpath(destination_folder * file * ".jld")
        
        # Save the data to file.
        meta_data = load_meta_data(path * file * ".txt")
        save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                               "Velocity", velocity_vector,
                               "Distance", distance_vector,
                               "Meta Data", meta_data)
    
        # Plot the map (debug).
        # plot(doppler_fft_matrix, distance_vector, velocity_vector)
    
    end

    println(" Done.")
    
end
