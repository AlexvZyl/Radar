# ================= #
#  I N C L U D E S  #
# ================= #

# Spurs (harmonics) causing some peaks.  Can be +- freq added.
# Laat RX langer hardloop as TX.  Laaste data

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
# pulsesToLoad 	= 30000
# pulsesToLoad 	= 15
# REMEMBER: The Doppler FFT removes two pulses.
folder 			= "Tests"

# Testing filenumbers.
# fileNumber 		= "000" # Bezier without DC shift.
# fileNumber 		= "001" # Bezier with DC shift.
# fileNumber 		= "017" # Bezier with large DC shift, normal eq.
# fileNumber 		= "018"

# Testing different shift values.
# fileNumber 		= "019"
# fileNumber 		= "020"
# fileNumber 		= "021"
# fileNumber 		= "023"
# fileNumber 		= "024"

# LFM.
# fileNumber 		= "025"
# fileNumber 		= "026"

# fileNumber 		= "029" # DC Ofsset.
# fileNumber 		= "030" # No DC Ofsset.
# fileNumber 		= "031" # LFM, No DC Ofsset.
# fileNumber 		= "033" # DC Ofsset with phase file.
# fileNumber 		= "034" # DC Ofsset with phase file.
# fileNumber 		= "035" # DC Ofsset no TX.

# fileNumber 		= "036"
fileNumber 		= "050"

# File location.
# path 			= "GitHub/SDR-Interface/build/Data/"
# path 			= "../SDR-Interface/build/Data/"
path 			= "../../../SDR-Interface/build/Data/"
filePrefix 		= "B210_SAMPLES_" * folder * "_"
file 			= path * folder * "/" * filePrefix * fileNumber
fileBin 		= file * ".bin"
fileTxt			= file * ".txt"	
phaseFile       = fileBin * "_PhaseShifts.bin"

# =========================== #
#  M E T A D A T A   F I L E  #
# =========================== #

dcFreqShift = 0

# Get the value from the string given the position.
function parseNumber(string::String, startIndex::Number)

	stringAns = ""
	index = startIndex
    while(string[index]!=' ' && string[index]!='\n')
		stringAns = stringAns * string[index]
		index += 1
        if index>length(string) break end
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
	elseif isnothing(findfirst("DC Frequency Offset Actual", line)) == false

		global dcFreqShift	 	= parseNumber(line, 29)
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

    # Total pulses.
	elseif isnothing(findfirst("Total pulses", line)) == false

		global totalPulses	 			= parseNumber(line, 15)

	end

end

println("Total pulses: ", totalPulses)

# ======================= #
#  B I N A R Y   F I L E  #
# ======================= #

rxSignal 		= loadDataFromBin(abspath(fileBin), pulsesToLoad = pulsesToLoad, samplesPerPulse = nSamplesPulse)
phaseDataArray = Vector{Complex{Float64}}(undef, Int(totalPulses))
phaseData       = read!(abspath(phaseFile), phaseDataArray)
# println(phaseDataArray)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #	

# Determine the TX signal.
if LFM
	# global txSignal = generateLFM(BW, fs, nSamplesWave, dcFreqShift)
	global txSignal = generateLFM(BW, fs, nSamplesWave, 0)
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
# figure = Figure(resolution = (1080, 1080))
# figure = Figure(resolution = (1920, 1920)) # Square
# Pulse Compression.
# display(rxSignal)

Imean = -0.004786199
Qmean = -0.002466153

rxSignal = rxSignal .- (Imean + im*Qmean)
PCsignal = pulseCompression(txSignal, rxSignal)
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

freqVal = dcFreqShift
if freqVal == 0 freqVal = 10000 end
plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [0,30], 
			   xRange = 2000, yRange = 100, nWaveSamples=nSamplesWave, plotDCBin = true, plotFreqLines = false, freqVal = freqVal)

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
display(figure)

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

# ======= #
#  E O F  #
# ======= #
