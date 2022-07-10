# ================= #
#  I N C L U D E S  #
# ================= #

include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Waveforms/LFM.jl")
include("Waveforms/NLFM.jl")
include("../../LowTB-NLFM/Source/Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")

using Statistics

# ================= #
#  S E T T I N G S  #
# ================= #

# Specify as 0 to load all the data.
# 0 : Loads all of the pulses.
pulsesToLoad 	= 0
# pulsesToLoad 	= 4
# REMEMBER: The Doppler FFT removes two pulses.
folder 			= "Tests"
# fileNumber 		= "027" # Bezier
# fileNumber 		= "020" # LFM
# fileNumber 		= "029" # Bezier With Offset
fileNumber 		= "058"

# =========== #
#  F I L E S  #
# =========== #

# path 			= "GitHub/SDR-Interface/build/Data/"
path 			= "../SDR-Interface/build/Data/"
filePrefix 		= "B210_SAMPLES_" * folder * "_"
file 			= path * folder * "/" * filePrefix * fileNumber
fileBin 		= file * ".bin"
fileTxt			= file * ".txt"	

# =========================== #
#  M E T A D A T A   F I L E  #
# =========================== #

dcFreqShift = 0

# Get the value from the string given the position.
function parseNumber(string::String, startIndex::Number)

	stringAns = ""
	index = startIndex
	while(string[index]!=' ')
		stringAns = stringAns * string[index]
		index += 1
	end
	return parse(Float32, stringAns)

end

global LFM = false
global NLFM = false

# Iterate over the file lines.
for line in eachline(abspath(fileTxt))

	# Sampling rate.
	if isnothing(findfirst("TX sampling rate", line)) == false

		global fs 				= trunc(Int32, parseNumber(line, 19)*1e6)
		
	# Center frequency.
	elseif isnothing(findfirst("TX wave frequency", line)) == false
		
		global fc 				= parseNumber(line, 20)*1e6

	# Wave samples.
	elseif isnothing(findfirst("Radar Waveform Samples", line)) == false

		global nSamplesWave 	= trunc(Int32, parseNumber(line, 25))

	# Pulse samples.
	elseif isnothing(findfirst("Radar Pulse Samples", line)) == false

		global nSamplesPulse 	= trunc(Int32, parseNumber(line, 22))

	# PRF 
	elseif isnothing(findfirst("PRF", line)) == false

		global PRF	 			= parseNumber(line, 6)

	# DC Offset
	elseif isnothing(findfirst("DC Frequency Offset", line)) == false

		global dcFreqShift	 	= parseNumber(line, 22)
		println("DC Shift: ", dcFreqShift)

	# Wave bandwidth.
	elseif isnothing(findfirst("Wave bandwidth", line)) == false

		global BW	 			= parseNumber(line, 17) * 1e6

	# Waveform type.
	elseif isnothing(findfirst("Wave type", line)) == false

		# LFM.
		if isnothing(findfirst("Linear Frequency Chirp", line)) == false
			global LFM = true
			global NLFM = false
		# NFLM.
		elseif isnothing(findfirst("Optimal Bezier", line)) == false
			global LFM = false
			global NFLM = true
		end
		
	end

end

# ======================= #
#  B I N A R Y   F I L E  #
# ======================= #

rxSignal 		= loadDataFromBin(abspath(fileBin), pulsesToLoad = pulsesToLoad, samplesPerPulse = nSamplesPulse)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #	

# Determine the TX signal.
if LFM
	global txSignal = generateLFM(BW, fs, nSamplesWave, dcFreqShift)
	global waveStr = "LFM"
else
	global txSignal = generateOptimalBezierCF32(nSamplesWave, BW, fs)
	global waveStr = "Bezier"
end

# ----------------------------------------- #
#  P R O C E S S I N G  &  P L O T T I N G  #
# ----------------------------------------- #

# Figure for plotting.
figure = Figure(resolution = (1920, 1080))
# figure = Figure(resolution = (1920, 1920)) # Square
# Pulse Compression.
PCsignal = pulseCompression(rxSignal, txSignal)

# plotSignal(figure, txSignal, [1,1], fs)
# plotSignal(figure, rxSignal, [1,1], fs)
# plotPowerSpectra(figure, txSignal, [1,1], fs, dB = true)
# plotPowerSpectra(figure, rxSignal, [1,1], fs, dB = true)
# plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal, yRange = 60, dB = true)
# PlotIQCircle(figure, txSignal, [1,1], title = string("I vs Q ", waveStr))
# PlotIQCircle(figure, rxSignal, [1,1], title = string("I vs Q ", waveStr))

plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [0,30], 
			   xRange = 600, yRange = 300, nWaveSamples=nSamplesWave, plotDCBin = false, plotFreqLines = true, freqVal = dcFreqShift)

# totalPulses = floor(Int, length(rxSignal)/nSamplesPulse)
# rxMatrix =  reshape((rxSignal), nSamplesPulse, :) 
# signalMean = mean(rxMatrix, dims=2)

# PCsignal = pulseCompression(rxSignal, txSignal)
# PCsignal = PCsignal[1:1:end-6]
# PCMatrix = reshape((PCsignal), nSamplesPulse, :)
# pcMean = mean(PCMatrix, dims=2)

# figure = Figure()
# ax = Axis(figure[1, 1], xlabel = "Amplitude (V)", ylabel = "Total", title = "RX Noise",
		#   titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# lines!(abs.(signalMean[:,1]))
# lines!(abs.(pcMean[:,1]))
# ax2 = Axis(figure[1, 2], xlabel = "Amplitude (V)", ylabel = "Total", title = "RX Noise",
# titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# heatmap!(abs.(rxMatrix))
# display(figure)

# fftMatrix = dopplerFFT(rxSignal, [1, nSamplesPulse*2], nSamplesPulse, PRF)
# velocityBinCount = length(fftMatrix[])

# plotPowerSpectra(figure, rxSignal, [1,1], fs)

# plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [20,120], 
			#    xRange = Inf, yRange = 40, nWaveSamples=nSamplesWave, plotDCBin = true)
				
# plotPowerSpectra(figure, rxSignal, [1,1], fs)
# Imean = -4.1903e-06
# Qmean = -9.71446e-07
# rxSignal = rxSignal .- (Imean + im*Qmean)

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

save("Testing.pdf", figure)
# save("LFM_REALDATA_SIGNAL.pdf", figure)
# save("LFM_REALDATA_SPECTRUM.pdf", figure)
# save("LFM_REALDATA_MF.pdf", figure)
# save("LFM_REALDATA_MFSYNCED.pdf", figure)
# save("LFM_REALDATA_DOPPLERFFT.pdf", figure)
# save("PhaseNoise_REALDATA_DIRECT.pdf", figure)
# save("PhaseNoise_REALDATA_VELD.pdf", figure)

# ======= #
#  E O F  #
# ======= #