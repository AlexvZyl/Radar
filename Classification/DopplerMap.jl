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

function calculate_doppler_map(file::String; return_doppler_only::Bool = false, pulses_to_load::Number = 0)

    file_bin = file * ".bin"
    file_txt = file * ".txt"	
    
    # Load the metadata.
    meta_data = load_meta_data(file_txt)
    
    # Load binary data.
    rx_signal = loadDataFromBin(abspath(file_bin), pulsesToLoad = pulses_to_load, samplesPerPulse = meta_data.pulse_sample_count)
    
    # TX Signal.
    if meta_data.wave_type == "LFM"
    	global tx_signal = generateLFM(meta_data.bandwidth, meta_data.sampling_freq, meta_data.wave_sample_count, 0)
    elseif meta_data.wave_type == "Bezier"
        global tx_signal = generateOptimalBezierCF32(meta_data.wave_sample_count, meta_data.bandwidth, Int32(meta_data.sampling_freq))
    elseif meta_data.wave_type == "Logit"
        global tx_signal, null = generateOptimalSigmoidForSDR(meta_data.wave_sample_count, meta_data.bandwidth, meta_data.sampling_freq)
    end
    
    # Pulse compression.
    pc_signal = pulseCompression(tx_signal, rx_signal)
    
    # Doppler fft.
    doppler_fft_matrix, distance_vector, velocity_vector = plotDopplerFFT(false, pc_signal, [1, 1], [1, meta_data.pulse_sample_count*2], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
    			                                        xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                        removeClutter = true, rawImage = false, return_doppler_fft = true)

    if return_doppler_only
        return doppler_fft_matrix
    end

    return doppler_fft_matrix, distance_vector, velocity_vector
    
end
