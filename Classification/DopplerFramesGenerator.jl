# Creates frames of the Doppler data instead of making on doppler map from all of the pules.

# Includes.
include("DopplerMap.jl")

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
file_number 	= "012"
frame_count     = 10
frame_advance   = 40000

# Fixed metdata.
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number

# Create frames from the meta data.
meta_data = load_meta_data(file * ".txt")
frames = create_frames(meta_data.total_pulses, frame_count, frame_advance)

# Calculate the doppler frames.
doppler_frames, distance_vector, velocity_vector = calculate_doppler_map(file, frames)

# Destination file.                                                    
destination_folder = "Data/DopplerFrames/" * folder * "/"
destination_file = destination_folder * file_prefix * file_number * ".jld"  

# Save the data to file.
save(destination_file, "Doppler FFT Frames", doppler_frames, 
                       "Velocity", velocity_vector,
                       "Distance", distance_vector)
