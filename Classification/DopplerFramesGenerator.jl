# Creates frames of the Doppler data instead of making on doppler map from all of the pules.

# Includes.
include("DopplerMap.jl")
include("Directories.jl")

# Create the frame based on the data provided.
# Frame advance is given in samples (or in the case of a doppler map, pulses).
function create_frames(total_pulses::Number, frame_count::Number, frame_advance::Number)

    # Checks.
    @assert frame_advance > 0 "Frame advance should be a positive number."
    @assert frame_count > 0 "Frame count should be a positive number."

    # Init frame data.
    frames = Vector{Frame}(undef, frame_count) 
    frame_size = total_pulses - (frame_count-1)*frame_advance
    @assert frame_size > frame_advance "Frame advance is larger than frame size, samples (pulses) will be skipped."

    # Populate frame vector.
    starting_position = 1
    for i in range(1, frame_count)    
        frames[i] = Frame(trunc(Int, starting_position), trunc(Int, starting_position + frame_size))       
        starting_position += frame_advance
    end

    # Change the size of the last frame to make sure all of them fit in nicely.
    # This should not have a large effect on the result.
    frames[end].last = total_pulses
    @assert size(frames[end]) > 0 "Last frame is incorrect."

    return frames
end

# Meta data.
folder 			= "Test"
load_all_files  = false
files_to_load   = [ 
    "012" 
]

# Frame data.
frame_count     = 2
frame_advance   = 100000

# Directories.
map_dir, cluster_dir, frames_dir = get_directories(folder)
# Get all of the files in the directory.
if load_all_files 
    files_to_load = readdir(map_dir)
# Convert the file numbers into files.
else
    for (i, number) in enumerate(files_to_load)
        files_to_load[i] = get_file_name(folder, number)
    end
end

println("Loading files:")
display(files_to_load)

# Calculate frames for each file.
for file in files_to_load

    # Create frames from the meta data.
    meta_data = load(get_file_path(map_dir, file))["Meta Data"]
    frames = create_frames(meta_data.total_pulses, frame_count, frame_advance)
    
    # Calculate the doppler frames.
    raw_file = "/home/alex/GitHub/SDR-Interface/build/Data/" * folder * "/" * splitdir(file)[2][1:end-4]
    doppler_frames, distance_vector, velocity_vector = calculate_doppler_map(raw_file, frames)
    
    # Destination file.                                                    
    destination_file = get_file_path(frames_dir, file)  
    
    # Save the data to file.
    save(destination_file, "Doppler FFT Frames", doppler_frames, 
                           "Velocity", velocity_vector,
                           "Distance", distance_vector,
                           "Frame Count", frame_count,
                           "Frame Advance", frame_advance)

end
