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

    @assert frame_size > frame_overlap "Supplied invalid values.  Frame overlap is larger than the size.  Reduce overlap or frame count."

    # Populate frame vector.
    for i in range(1, frame_count)    
        frames[i] = Frame(starting_position, starting_position + frame_size)       
        starting_position += frame_size - frame_overlap / 2
    end

    # Change the size of the last frame to make sure all of them fit in nicely.
    # This should not have a large effect on the result.
    frames[end].last = total_pulses

    @assert size(frames[end]) >= 0 "Last frame is not valid.  Should probably reduce the amount of frames." 

    return frames
end

# Meta data.
folder 			= "Test"
file_number 	= "012"
frame_count     = 1
frame_overlap   = 10 # In pulses.

# Fixed metdata.
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number

# Create frames from the meta data.
meta_data = load_meta_data(file * ".txt")
frames = create_frames(meta_data.total_pulses, frame_count, frame_overlap)

# Calculate the doppler frames.
doppler_frames, distance_vector, velocity_vector = calculate_doppler_map(file, frames)
    
# Debugging.
plot(amp2db.(abs.(doppler_frames[1])), distance_vector, velocity_vector)

# Destination file.                                                    
# destination_folder = "Data/" * folder * "/"
# destination_file = destination_folder * file * ".jld"  

# Save the data to file.
# save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                       # "Velocity", velocity_vector,
                       # "Distance", distance_vector)
