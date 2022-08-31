# Processes the raw IQ samples from the SDR and stores the comples FFT results
# in a file so that the clustering can take place.

using JLD

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
        tx_signal, null = generateOptimalSigmoidForSDR(meta_data.wave_sample_count, meta_data.bandwidth, meta_data.sampling_freq)
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
    rx_signal = loadDataFromBin(abspath(file_bin), pulsesToLoad = pulses_to_load, samplesPerPulse = meta_data.pulse_sample_count)
    
    # TX Signal.
    tx_signal = generate_tx_signal(meta_data) 
    
    # Pulse compression.
   pc_signal = pulseCompression(tx_signal, rx_signal)
    
    # Doppler fft.
    doppler_fft_matrix, distance_vector, velocity_vector = plotDopplerFFT(false, pc_signal, [1, 1], [1, meta_data.pulse_sample_count*2], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
    			                                                          xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                                          removeClutter = true, rawImage = false, return_doppler_fft = true)

    # Returning.
    if return_doppler_only return doppler_fft_matrix end
    return doppler_fft_matrix, distance_vector, velocity_vector
    
end

# Calculate the doppler map for the given frames.
function calculate_doppler_map(file::String, frames::Vector{Frame}; return_doppler_only::Bool = false, pulses_to_load::Number = 0)

    # Files.
    file_bin = file * ".bin"
    file_txt = file * ".txt"	
    
    # Load the metadata.
    meta_data = load_meta_data(file_txt)
    
    # Load binary data.
    rx_signal = loadDataFromBin(abspath(file_bin), pulsesToLoad = pulses_to_load, samplesPerPulse = meta_data.pulse_sample_count)

    # TX Signal.
    tx_signal = generate_tx_signal(meta_data) 
     
    # Run this one time so that we can get the distance and velocity vetor.
    # Definitely not the best way of doing this but oh well.
    pc_signal = pulseCompression(tx_signal, rx_signal[frames[1].first:frames[1].last])       
    null, distance_vector, velocity_vector = plotDopplerFFT(false, pc_signal, [1, 1], [1, meta_data.pulse_sample_count*2], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
 		                                                    xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                            removeClutter = true, rawImage = false, return_doppler_fft = true)

    # Calculate doppler maps for each frame.
    doppler_frames = Vector{AbstractMatrix}(undef, 0)
    for frame in frames

        # Pulse compression.
        pc_signal = pulseCompression(tx_signal, rx_signal[frame.first:frame.last])       

        # Calculate doppler matrix.
        doppler_fft_matrix, null1, null2 = plotDopplerFFT(false, pc_signal, [1, 1], [1, meta_data.pulse_sample_count*2], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
    			                                          xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                          removeClutter = true, rawImage = false, return_doppler_fft = true)

        # Add current doppler matrix to the list of frames.
        push!(doppler_frames, doppler_fft_matrix)

    end

    # Returning. 
    if return_doppler_only return doppler_frames end
    return doppler_frames, distance_vector, velocity_vector

end

# Plot a Doppler heatmap.
# Creates a new figure and axis, so only for debugging really.
function plot(doppler_fft_matrix::AbstractMatrix, distance_vector::AbstractRange, velocity_vector::AbstractRange; dB::Bool = true, snr_threshold::Number = 15)

    # Create the figure and axis. 
    figure = Figure()
    axis = Axis(figure[1,1])

    # Calculate dB.
    if dB
        doppler_fft_matrix = 20*log10.(abs.(doppler_fft_matrix))
    end

    # Plot and display.
    hm = heatmap!(figure[1, 1], distance_vector, velocity_vector, doppler_fft_matrix, colorrange = [snr_threshold, 20])
    display(figure)

end
