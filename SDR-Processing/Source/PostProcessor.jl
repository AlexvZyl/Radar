# ================= #
#  I N C L U D E S  #
# ================= #

# Spurs (harmonics) causing some peaks.  Can be +- freq added.
# Laat RX langer hardloop as TX.  Laaste data

# Modules.
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Waveforms/LFM.jl")
include("Waveforms/NLFM.jl")
include("../../LowTB-NLFM/Source/Bezier.jl")
include("../../LowTB-NLFM/Source/Sigmoid.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("../../Classification/DopplerMap.jl")
using Statistics

# ================= #
#  S E T T I N G S  #
# ================= #

# Specify as 0 to load all the data.
# 0 : Loads all of the pulses.
# pulsesToLoad 	= 0
# pulsesToLoad 	= 30000
# pulsesToLoad 	= 10

# pulsesToLoad 	= 5
# REMEMBER: The Doppler FFT removes two pulses.
# folder 			= "Test"
# fileNumber 		= "012"

# File location.
# path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
# filePrefix 		= "B210_SAMPLES_" * folder * "_"
# file 			= path * folder * "/" * filePrefix * fileNumber
# fileBin 		= file * ".bin"
# fileTxt			= file * ".txt"	
# phaseFile       = fileBin * "_PhaseShifts.bin"

# =========================== #
#  M E T A D A T A   F I L E  #
# =========================== #

# dcFreqShift = 0
# global LFM = false
# global NLFM = false

# println("Total pulses: ", totalPulses)

# ======================= #
#  B I N A R Y   F I L E  #
# ======================= #

# rxSignal 		= loadDataFromBin(abspath(fileBin), pulsesToLoad = pulsesToLoad, samplesPerPulse = nSamplesPulse)
# phaseDataArray = Vector{Complex{Float64}}(undef, Int(totalPulses))
# phaseData       = read!(abspath(phaseFile), phaseDataArray)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #	

# Determine the TX signal.
# if waveStr=="LFM"
# 	global txSignal = generateLFM(BW, fs, nSamplesWave, 0)
# elseif waveStr=="Bezier"
# 	global txSignal = generateOptimalBezierCF32(nSamplesWave, BW, fs)
# elseif waveStr=="Logit"
#     global txSignal, null = generateOptimalSigmoidForSDR(nSamplesPulse, BW, fs)
# else
#     AssertionError("Unknown waveform.")
# end
# println("Wave type: " * waveStr)            

# ----------------------------------------- #
#  P R O C E S S I N G  &  P L O T T I N G  #
# ----------------------------------------- #

# Change the theme for the raw image.
#rawImage = true
#if rawImage
#    update_theme!(figure_padding = (0, 0, 0, 0))
#end

# Figure for plotting.
# figure = Figure(resolution = (1920, 1080))
# figure = Figure()
# figure = Figure(resolution = (1080, 1080))
# figure = Figure(resolution = (1920, 1920)) # Square

# rxSignal = rxSignal .- (Imean + im*Qmean)
# PCsignal = pulseCompression(txSignal, rxSignal)
# pulseMatrix = splitMatrix(PCsignal, nSamplesPulse, [1, nSamplesPulse*2])
# pulseMatrix = splitMatrix(rxSignal, nSamplesPulse, [1, nSamplesPulse*2])
# ax = Axis(figure[1, 1], xlabel = "", ylabel = "", title = "")
# heatmap!(figure[1,1], log10.(pulseMatrix))

# Plot the phase shift complex component.
# plotSignal(figure, phaseDataArray, [1,1], fs)
# ax = Axis(figure[1, 1], xlabel = "", ylabel = "", title = "")
# lines!(angle.(phaseDataArray), color = :blue)
  
# plotSignal(figure, txSignal, [1,1], fs)
# plotSignal(figure, rxSignal, [1,1], fs)
# plotPowerSpectra(figure, txSignal, [1,1], fs, dB = true)
# plotPowerSpectra(figure, rxSignal, [1,1], fs, dB = true)
# plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal, yRange = 60, dB = true)
# PlotIQCircle(figure, txSignal, [1,1], title = string("I vs Q ", waveStr))
# PlotIQCircle(figure, rxSignal, [1,1], title = string("I vs Q ", waveStr))

# freqVal = dcFreqShift
# if freqVal == 0 freqVal = 10000 end
# plotDopplerFFT(figure, PCsignal, [1, 1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [10, 20], 
			   # xRange = 500, yRange = 250, nWaveSamples=nSamplesWave, plotDCBin = true, plotFreqLines = false, freqVal = freqVal)
			   # xRange = max_range, yRange = 5, nWaveSamples=nSamplesWave, plotDCBin = false, plotFreqLines = true, freqVal = freqVal,
               # removeClutter = true, rawImage = rawImage)

# totalPulses = floor(Int, length(rxSignal)/nSamplesPulse)
# rxMatrix =  reshape((rxSignal), nSamplesPulse, :) 
# signalMean = mean(rxMatrix, dims=2)

# PCsignal = pulseCompression(rxSignal, txSignal)
# PCsignal = PCsignal[1:1:end-6]
# PCMatrix = reshape((PCsignal), nSamplesPulse, :)
# pcMean = mean(PCMatrix, dims=2)

# figure = Figure()
# ax = Axis(figure[1, 1], xlabel = "Amplitude (V)", ylabel = "Total", title = "RX Noise",
		  # titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# lines!(abs.(signalMean[:,1]))
# lines!(abs.(pcMean[:,1]))
# ax2 = Axis(figure[1, 2], xlabel = "Amplitude (V)", ylabel = "Total", title = "RX Noise",
# titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# heatmap!(abs.(rxMatrix))
# display(figure)
# save("Testing.pdf", figure)
# save("Doppler.png", figure)
# save("DopplerThreshold.png", figure)

# fftMatrix = dopplerFFT(rxSignal, [1, nSamplesPulse*2], nSamplesPulse, PRF)
# velocityBinCount = length(fftMatrix[])

# plotPowerSpectra(figure, rxSignal, [1,1], fs)

# plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [20,120], 
			#    xRange = Inf, yRange = 40, nWaveSamples=nSamplesWave, plotDCBin = true)
				
# plotPowerSpectra(figure, rxSignal, [1,1], fs)
# Imean = -4.1903e-06
# Qmean = -9.71446e-07
# rxSignal = rxSignal .- (Imean + im*Qmean)v

# plotPowerSpectra(figure, rxSignal, [1,1], fs, title = "LFM Frequency Spectrum", dB = true)

# plotSignal(figure, rxSignal, [1,1], fs, title = "LFM Received Signal")
# plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal, dB = true, title = "LFM Matched Filter Response", timeFromZero = true)
# syncedPCSignal, ax = syncPulseCompressedSignal(PCsignal, nSamplesPulse, [1,nSamplesPulse], plot = true, figure = figure)
# plotPulseMatrix(figure, rxSignal, [1,1], fs, nSamplesPulse, [-5, 10])

# ax = Axis(figure[1, 1], xlabel = "Amplitude (V)", ylabel = "Total OcScurances", title = "RX Noise",
		#   titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# plotOrigin(ax)
# hist!(real(rxSignal), bins = 100)
# hist!(imag(rxSignal), bins = 100)

# ------------------------- #
#  S A V I N G   P L O T S  #
# ------------------------- #

# save("PostProcessorResult.pdf", figure)
# save("LFM_REALDATA_SIGNAL.pdf", figure)
# save("LFM_REALDATA_SPECTRUM.pdf", figure)
# save("LFM_REALDATA_MF.pdf", figure)
# save("LFM_REALDATA_MFSYNCED.pdf", figure)
# save("LFM_REALDATA_DOPPLERFFT.pdf", figure)
# save("PhaseNoise_REALDATA_DIRECT.pdf", figure)
# save("PhaseNoise_REALDATA_VELD.pdf", figure)

# ------------------- #
#  F U N C T I O N S  #
# ------------------- #

function process_intput(folder::String, fileNumber::String; pulsesToLoad = 0, snr_min::Number = 13)

    # File data.
    path 			= "/home/alex/GitHub/SDR-Interface/build/Data/"
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
                   removeClutter = false, rawImage = false)
    
    return figure

end
    
# ======= #
#  E O F  #
# ======= #
