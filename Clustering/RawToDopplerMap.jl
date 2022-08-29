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

# Meta data.
folder 			= "Test"
file_number 	= "012"

# Fixed meta data.
path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
file_prefix 	= "B210_SAMPLES_" * folder * "_"
file 			= file_prefix * file_number
file_bin 		= path * folder * "/" * file * ".bin"
file_txt		= path * folder * "/" * file * ".txt"	

# Load the metadata.
meta_data = load_meta_data(file_txt)
display(meta_data)

# Load binary data.
pulses_to_load 	= 0  # Specify 0 to load all the data.
rx_signal 		= loadDataFromBin(abspath(file_bin), pulsesToLoad = pulses_to_load, samplesPerPulse = meta_data.pulse_sample_count)

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
doppler_fft_matrix, range_vector, velocity_vector = plotDopplerFFT(false, pc_signal, [1, 1], [1, meta_data.pulse_sample_count*2], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [10, 20], 
			                                        xRange = meta_data.max_range, yRange = 5, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = 100000,
                                                    removeClutter = true, rawImage = false, return_doppler_fft = true)

# Destination file.                                                    
destination_folder = "Data/" * folder * "/"
destination_file = destination_folder * file * ".jld"  

# Save the data to file.
save(destination_file, "Doppler FFT Matrix", doppler_fft_matrix, 
                       "Velocity", velocity_vector,
                       "Range", range_vector)
