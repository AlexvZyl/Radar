# ================= #
#  I N C L U D E S  #
# ================= #

include("../PlotUtilities.jl")
include("BinaryProcessor.jl")
include("../Waveforms/LFM.jl")
include("../Waveforms/NLFM.jl")
include("DopplerFFT.jl")
include("PulseCompression.jl")

# ================= #
#  S E T T I N G S  #
# ================= #

# Specify as 0 to load all the data.
pulsesToLoad 	= 10000
folder 			= "RietVleiTestingDay1"
fileNumber 		= "041"
# fileNumber 		= "043"

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

	#  P R O C E S S I N G  #

    PCsignal = pulseCompression(rxSignal, txSignal)
    figure = Figure()
	plotSignal(figure, rxSignal, [1,1], fs)
	# plotMatchedFilter(figure, rxSignal, [1,1], fs, secondSignal = txSignal)
	# plotDopplerFFT(figure, PCsignal, [1,1], [1, nSamplesPulse*1], fc, fs, nSamplesPulse, [0,40], 
				#    xRange = 10, yRange = Inf, nWaveSamples=nSamplesWave)
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