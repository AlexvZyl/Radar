# ================= #
#  I N C L U D E S  #
# ================= #

include("../PlotUtilities.jl")
include("BinaryProcessor.jl")
include("../Waveforms/LFM.jl")
include("../Waveforms/NLFM.jl")
include("DopplerFFT.jl")
include("PulseCompression.jl")
include("Synchroniser.jl")
include("PulseMatrix.jl")

using Statistics
using SharedArrays

# ================= #
#  S E T T I N G S  #
# ================= #

# Specify as 0 to load all the data.
pulsesToLoad 	= 0
folder 			= "Testing"
fileNumber 		= "046"

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

# Variables used.
fs=0; fc=0; nSamplesPulse=0; nSamplesWave=0; PRF=0; LFM=false; NLFM=false;

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

	# Waveform type.
	elseif isnothing(findfirst("Wave type", line)) == false

		# LFM.
		if isnothing(findfirst("Linear Frequency Chirp", line)) == false

			global LFM = true
			global NLFM = false

		# NFLM.
		elseif isnothing(findfirst("Non-Linear Frequency Chirp", line)) == false

			global LFM = false
			global NFLM = true

		end
		
	end

end

BW 				= fs / 2.1		

# ======================= #
#  B I N A R Y   F I L E  #
# ======================= #

rxSignal 		= loadDataFromBin(abspath(fileBin), pulsesToLoad = pulsesToLoad, samplesPerPulse = nSamplesPulse)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #	

# --------- #
#   L F M   #
# --------- #

if LFM

	#  W A V E F O R M  #

	local txSignal = generateLFM(BW, fs, nSamplesWave)

	# totalPulses = floor(Int, length(rxSignal)/nSamplesPulse)
	# rxMatrix =  reshape((rxSignal), nSamplesPulse, :) 
	# signalMean = mean(rxMatrix, dims=2)
	
	#  P R O C E S S I N G  #
	
    PCsignal = pulseCompression(rxSignal, txSignal)
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

	# P L O T T I N G  #

    figure = Figure()

	# fftMatrix = dopplerFFT(rxSignal, [1, nSamplesPulse*2], nSamplesPulse, PRF)
	# velocityBinCount = length(fftMatrix[])

	# plotPowerSpectra(figure, rxSignal, [1,1], fs)

	plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [50,120], 
				   xRange = Inf, yRange = 40, nWaveSamples=nSamplesWave, plotDCBin = true)
				   
	# plotPowerSpectra(figure, rxSignal, [1,1], fs)
	# Imean = mean(real(rxSignal))
	# Qmean = mean(imag(rxSignal))
	Imean = -2.59602e-06 -3.15151e-06 
	Qmean = -2.11107e-06 -1.80966e-06 
	# rxSignal = rxSignal .- (Imean + im*Qmean)

	# plotPowerSpectra(figure, rxSignal, [1,2], fs)

	# plotSignal(figure, rxSignal, [1,1], fs)
	# plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal)
    # PCsignal = pulseCompression(rxSignal, txSignal)
	# plotDopplerFFT(figure, PCsignal, [2,1], [1, nSamplesPulse*2], fc, fs, nSamplesPulse, [0,120], 
				#    xRange = Inf, yRange = 40, nWaveSamples=nSamplesWave)
	# syncedPCSignal = syncPulseCompressedSignal(PCsignal, nSamplesPulse, [1,nSamplesPulse])
	# plotPulseMatrix(figure, rxSignal, [1,1], fs, nSamplesPulse, [-5, 10])

	# ax = Axis(figure[1, 1], xlabel = "Amplitude (V)", ylabel = "Total OcScurances", title = "RX Noise",
			#   titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	# plotOrigin(ax)
	# hist!(real(rxSignal), bins = 100)
	# hist!(imag(rxSignal), bins = 100)

    display(figure)

end

# --------- #
#  N L F M  #
# --------- #

if NLFM

	#  W A V E F R O M  #

	local txSignal = generateNLFM(BW, fs, nSamplesWave)

	#  P R O C E S S I N G  #

	# Plot NLFM.
	
    # Plot the signal.
	PCsignal = pulseCompression(rxSignal, txSignal)

	figure = Figure()
    # plotSignal(figure, txSignal, [1,1], fs)
	# plotPowerSpectra(figure, txSignal, [1,2], fs)
	plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal)
	# plotDopplerFFT(figure, PCsignal, [1,1], [1,nSamplesPulse*5], fc, fs, nSamplesPulse, [0,100], 
				#    xRange = Inf, yRange = 60, nWaveSamples=nSamplesWave)
    display(figure)

end

# ======= #
#  E O F  #
# ======= #