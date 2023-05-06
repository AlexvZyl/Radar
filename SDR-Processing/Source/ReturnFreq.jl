include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("../../Classification/DopplerMap.jl")

# File data.
path 			= "/home/alex/Repositories/Radar/SDR-Processing/Source/Data/"
folder          = "ThesisPipeline"
fileNumber      = "007"
filePrefix 		= "B210_SAMPLES_" * folder * "_"
file 			= path * folder * "/" * filePrefix * fileNumber
fileBin 		= file * ".bin"
fileTxt			= file * ".txt"	

# Specify as 0 to load all the data.
# 0 : Loads all of the pulses.
# REMEMBER: The Doppler FFT removes two pulses.
pulsesToLoad = 3

# Metadata.
meta_data = load_meta_data(fileTxt)
println("Wave type: " * meta_data.wave_type)            

# Setup plotting.
figure = Figure(resolution = (1920, 1080))

# Create signals.
rx_signal = loadDataFromBin(abspath(fileBin), meta_data, pulsesToLoad = pulsesToLoad)
tx_signal = generate_tx_signal(meta_data)

# Pulse compression and syncing.
comp_signal = pulseCompression(tx_signal, rx_signal)
sync_index = get_sync_index(comp_signal, meta_data, pulses_to_search = 2) - meta_data.wave_sample_count
rx_signal = sync_signal(rx_signal, sync_index, meta_data)

# Extract the pulses only.
pulses = pulsesToLoad!=0 ? pulsesToLoad - 2 : meta_data.total_pulses-2
rx_signal = vcat([ 
    rx_signal[pos:pos+meta_data.wave_sample_count] 
    for pos in 1:meta_data.pulse_sample_count:pulses*meta_data.pulse_sample_count
]...)

# Zero pad.
rx_signal = vcat(rx_signal, zeros(ComplexF32, 1000))
tx_signal = vcat(tx_signal, zeros(ComplexF32, 1000))

#plotSignal(figure, rx_signal, [1,1], meta_data.sampling_freq)
plotPowerSpectra(figure, rx_signal, [1,1], meta_data.sampling_freq, dB = true)
#plotPowerSpectra(figure, tx_signal, [1,1], meta_data.sampling_freq, dB = true)
save("RX_Sampled_Signal_Freq.pdf", figure)
