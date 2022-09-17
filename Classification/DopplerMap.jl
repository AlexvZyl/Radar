# Processes the raw IQ samples from the SDR and stores the comples FFT results
# in a file so that the clustering can take place.

using JLD
using Clustering
using Base.Threads

# Includes.
include("../Utilities/MakieGL/PlotUtilities.jl")
include("../SDR-Processing/Source/Waveforms/LFM.jl")
include("../SDR-Processing/Source/Waveforms/NLFM.jl")
include("../LowTB-NLFM/Source/Bezier.jl")
include("../LowTB-NLFM/Source/Sigmoid.jl")
include("../Utilities/Processing/ProcessingHeader.jl")
include("../Utilities/Processing/BinaryProcessor.jl")

# Describes the frame.
mutable struct Frame
    first::Int
    last::Int
end

# Get the frame size.
function size(frame::Frame)
    return frame.last - frame.first + 1
end

# Generate the TX signal based on the meta data.
function generate_tx_signal(meta_data::Meta_Data)

    if meta_data.wave_type == "LFM"
    	return generateLFM(meta_data.bandwidth, meta_data.sampling_freq, meta_data.wave_sample_count, 0)

    elseif meta_data.wave_type == "Bezier"
        return generateOptimalBezierCF32(meta_data.wave_sample_count, meta_data.bandwidth, Int32(meta_data.sampling_freq))

    elseif meta_data.wave_type == "Logit"
        tx_signal = generateOptimalSigmoidForSDR(meta_data.wave_sample_count, meta_data.bandwidth, meta_data.sampling_freq)[1]
        return tx_signal
    end

    @assert false "Not a valid wave type."
end

# Calculate the doppler map.
function calculate_doppler_map(file::String; return_doppler_only::Bool = false, pulses_to_load::Number = 0)

    # Files.
    file_bin = file * ".bin"
    file_txt = file * ".txt"	
    
    # Load the metadata.
    meta_data = load_meta_data(file_txt)
    
    # Load binary data.
    rx_signal = loadDataFromBin(abspath(file_bin), meta_data, pulsesToLoad = pulses_to_load)
    
    # TX Signal.
    tx_signal = generate_tx_signal(meta_data) 
    
    # Pulse compression.
    pc_signal = pulseCompression(tx_signal, rx_signal)
    
    # Sync the TX signal.
    synced_signal = sync_signal(pc_signal, get_sync_index(pc_signal, meta_data, pulses_to_search = 2), meta_data)

    # Doppler fft.
    doppler_fft_matrix, distance_vector, velocity_vector = plotDopplerFFT(false, synced_signal, [1, 1], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
    			                                                          xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                                          removeClutter = true, rawImage = false, return_doppler_fft = true)

    # Returning.
    if return_doppler_only return doppler_fft_matrix end
    return doppler_fft_matrix, distance_vector, velocity_vector
    
end

# Get the sample range from the frame and meta data.
function get_sample_range(frame::Frame, meta_data::Meta_Data)
    first = ( (frame.first-1) * meta_data.pulse_sample_count ) + 1
    last = frame.last * meta_data.pulse_sample_count 
    return first:1:last
end

# Calculate the doppler map for the given frames.
function calculate_doppler_map(file::String, frames::Vector{Frame}; return_doppler_only::Bool = false, pulses_to_load::Number = 0)

    # Files.
    file_bin = file * ".bin"
    file_txt = file * ".txt"	
    
    # Load the metadata.
    meta_data = load_meta_data(file_txt)
    
    # Load binary data.
    rx_signal = loadDataFromBin(abspath(file_bin), meta_data, pulsesToLoad = pulses_to_load)
    
    # TX Signal.
    tx_signal = generate_tx_signal(meta_data) 

    # Calculate doppler maps for each frame.
    doppler_frames = Vector{AbstractMatrix}(undef, length(frames))
    distance_vector = AbstractRange
    velocity_vector = AbstractRange

    # Pulse compression.
    pc_signal = pulseCompression(tx_signal, rx_signal)

    # Sync the signal.
    pc_signal = sync_signal(pc_signal, get_sync_index(pc_signal, meta_data, pulses_to_search = 2), meta_data)

    # Calculate the doppler frames.
    Threads.@threads for index in range(1, length(frames))

        # Extract the frame data from the pulse compressed signal.
        signal = pc_signal[get_sample_range(frames[index], meta_data)]

        # We need to padd the signal since the frames are going to be smaller than the entire signal.
        padding_count = meta_data.total_pulses - size(frames[index])

        # Calculate doppler matrix.
        doppler_fft_matrix, distance_vector, velocity_vector = plotDopplerFFT(false, signal, [1, 1], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
    			                                               xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                               removeClutter = true, rawImage = false, return_doppler_fft = true, padding_count = padding_count)

        # Add current doppler matrix to the list of frames.
        doppler_frames[index] = doppler_fft_matrix

    end

    # Returning. 
    if return_doppler_only return doppler_frames end
    return doppler_frames, distance_vector, velocity_vector

end

# Plot a Doppler heatmap.
# Creates a new figure and axis, so only for debugging really.
function plot(doppler_fft_matrix::AbstractMatrix, distance_vector::AbstractRange, velocity_vector::AbstractRange; dB::Bool = true, snr_threshold::Number = 15,
              existing_figure = false)

    figure = nothing
    if existing_figure == false   
        # Create the figure and axis. 
        figure = Figure()
        Axis(figure[1,1])
    else
        figure = existing_figure
    end

    # Calculate dB.
    if dB
        doppler_fft_matrix = 20*log10.(abs.(doppler_fft_matrix))
    end

    # Plot and display.
    heatmap!(figure[1, 1], distance_vector, velocity_vector, doppler_fft_matrix, colorrange = [snr_threshold, 20])
    display(figure)

end

# Animate the doppler frames on a figure.
function animate(doppler_frames::Vector{AbstractMatrix}, distance::AbstractRange, velocity::AbstractRange; 
                 sleep_seconds::Number = 0.5, snr_threshold::Number = 13, clusters = nothing,
                 adjacency_matrix = nothing, snr_max = 20, use_db::Bool = true)

    # Create the figure and axis. 
    figure = Figure()
    Axis(figure[1,1])
    display(figure)

    # Get the dB of the doppler data.
    doppler_frames_db = Vector{AbstractMatrix}(undef, length(doppler_frames))
    if use_db
        for (index, frame) in enumerate(doppler_frames)
            doppler_frames_db[index] = amp2db.(abs.(frame))
        end
    else
        doppler_frames_db = doppler_frames
    end

    # Setup clusters data.
    distance_data = nothing
    velocity_data = nothing
    if clusters !== nothing

        # We must have this matrix if clusters are passed.
        @assert adjacency_matrix !== nothing

        # Init.
        distance_data = Vector{Vector{Float64}}(undef, length(clusters))
        velocity_data = Vector{Vector{Float64}}(undef, length(clusters))   

        # Load the data.
        for (c, cluster) in enumerate(clusters)
            distance_temp = Vector{Float64}(undef, cluster.size)
            velocity_temp = Vector{Float64}(undef, cluster.size)
            # Populate data.
            for (i, index) in enumerate(cluster.core_indices)
                distance_temp[i] = adjacency_matrix[1, index]
                velocity_temp[i] = adjacency_matrix[2, index]
            end
            for (i, index) in enumerate(cluster.boundary_indices)
                distance_temp[i] = adjacency_matrix[1, index]
                velocity_temp[i] = adjacency_matrix[2, index]
            end
            distance_data[c] = distance_temp
            velocity_data[c] = velocity_temp
        end

    end

    colormap = to_colormap(:seaborn_bright)

    # Keep looping until the user interrupts.
    while true
        
        # Iterate and display the frames.
        for (index, frame) in enumerate(doppler_frames_db)
            # Plot and display.
            heatmap!(figure[1, 1], distance, velocity, frame, colorrange = [snr_threshold, snr_max])
            # Render clustering data.
            if clusters !== nothing
                color_index = 1
                for (distance, velocity) in zip(distance_data, velocity_data)
                    scatter!(distance, velocity, markersize = 4, color = (colormap[color_index], 0.85))
                    color_index += 1
                end
            end
            text!(distance[1] , velocity[1], text = "Frame Index: " * string(index))
            sleep(sleep_seconds)
        end

    end
end
