# ====================== #
#       Includes 		 #
# ====================== #

# File used to be able to have the same linearChirpform description
# in all of the different scripts.
include("Utilities.jl")

# ====================== #
#     Linear Chirp       #
# ====================== #

linearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

gradient = (bandwidth) / (chirpNSamples - 1)
index = 1
for n in samples
	FREQ = ((gradient * (index-1)) - (bandwidth/2))/samplingFreq
	linearChirp[index] = exp(n * -2 * pi * FREQ * im)
 	global index += 1
end

# Transmission
gradient2 = (bandwidth) / (HDChirpNSamples - 1)
index2 = 1
for n in HSamples
	FREQ = (((gradient2 * (index2-1)) - (bandwidth/2))/HDSamplingFreq)
	HDLinearChirp[index2] = exp(n * -2 * pi * FREQ * im)
	global index2 += 1
end

# ====================== #
#   Non Linear Chirp     #
# ====================== #

nonLinearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDNonLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

gradient = (bandwidth) / (chirpNSamples - 1)
index = 1
for n in samples
	FREQ = ((gradient * (index-1)) - (bandwidth/2))/samplingFreq
	linearChirp[index] = exp(n * -2 * pi * FREQ * im)
 	global index += 1
end

# Transmission
gradient2 = (bandwidth) / (HDChirpNSamples - 1)
index2 = 1
for n in HSamples
	FREQ = (((gradient2 * (index2-1)) - (bandwidth/2))/HDSamplingFreq)
	HDLinearChirp[index2] = exp(n * -2 * pi * FREQ * im)
	global index2 += 1
end

# ====================== #
#     Draw the plot.     #
# ====================== #

# Create figure.
fig = Figure()



# HD TX Pulse.
plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 40, xRange = 2)
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="TX Linear Chirp Pulse")
plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0, dB = true, title="TX Pusle PSD", xRange = 50, yRange = 40)
display(fig)

# ====================== #
#  		   EOF	   	     #
# ====================== #
