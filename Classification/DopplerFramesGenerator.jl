# Creates frames of the Doppler data instead of making on doppler map from all of the pules.

# Includes.
include("DopplerMap.jl")

# Create the frame based on the data provided.
# Overlap should be given in pulses.
function create_frames(total_pulses::Number, frame_count::Number, frame_overlap::Number)

    # Init frame data.
    frames = Vector{Frame}(undef, frame_count) 
    frame_size = floor( ( total_pulses + (frame_overlap * (frame_count-1) ) ) / frame_count )
    starting_position = 1

    @assert frame_size > 2*frame_overlap "Frame overlap is larger than half the frame size.  Reduce overlap or frame count."

    # Populate frame vector.
    for i in range(1, frame_count)    
        frames[i] = Frame(trunc(Int, starting_position), trunc(Int, starting_position + frame_size))       
        starting_position += frame_size - frame_overlap / 2
    end

    # Change the size of the last frame to make sure all of them fit in nicely.
    # This should not have a large effect on the result.
    frames[end].last = total_pulses

    return frames
end

# Meta data.
folder 			= "Test"
file_number 	= "012"
frame_count     = 5

# Fixed metdata.
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number

# Create frames from the meta data.
meta_data = load_meta_data(file * ".txt")
frame_overlap = trunc(Int, (meta_data.total_pulses / frame_count) / 2) - 1
frames = create_frames(meta_data.total_pulses, frame_count, frame_overlap)

# Calculate the doppler frames.
doppler_frames, distance_vector, velocity_vector = calculate_doppler_map(file, frames)

# Debugging.
plot(abs.(doppler_frames[1]), distance_vector, velocity_vector, snr_threshold = 0)

# Destination file.                                                    
destination_folder = "Data/DopplerFrames/" * folder * "/"
destination_file = destination_folder * file_prefix * file_number * ".jld"  

# Save the data to file.
save(destination_file, "Doppler FFT Frames", doppler_frames, 
                       "Velocity", velocity_vector,
                       "Distance", distance_vector)
