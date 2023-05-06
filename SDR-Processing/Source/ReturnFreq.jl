include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")

# File data.
path 			= "/home/alex/Repositories/Radar/SDR-Processing/Source/Data/"
folder          = "ThesisPipeline"
fileNumber      = "001"
filePrefix 		= "B210_SAMPLES_" * folder * "_"
file 			= path * folder * "/" * filePrefix * fileNumber
fileBin 		= file * ".bin"
fileTxt			= file * ".txt"	

# Get metadata.
meta_data = load_meta_data(fileTxt)
println("Wave type: " * meta_data.wave_type)            

# Setup plotting.
figure = Figure(resolution = (1920, 1080))

# Create signals.
rx_signal = loadDataFromBin(abspath(fileBin), meta_data, pulsesToLoad = pulsesToLoad)
tx_signal = generate_tx_signal(meta_data)

# Circle.
# PlotIQCircle(figure, rx_signal, [1,1], title = string("I vs Q ", meta_data.wave_type))
# display(figure)
# return

# Pulse compression and syncing.
rx_signal = pulseCompression(tx_signal, rx_signal)
rx_signal = sync_signal(rx_signal, get_sync_index(rx_signal, meta_data, pulses_to_search = 2), meta_data)
    
freqVal = meta_data.dc_freq_shift
if freqVal == 0 freqVal = 10000 end
plotDopplerFFT(figure, rx_signal, [1, 1], meta_data.center_freq, Int32(meta_data.sampling_freq), meta_data.pulse_sample_count, [snr_min, 20], 
			   xRange = meta_data.max_range, yRange = 8, nWaveSamples=meta_data.wave_sample_count, plotDCBin = false, plotFreqLines = false, freqVal = freqVal,
               removeClutter = true, rawImage = false)
