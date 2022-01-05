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
for n in HDSamples
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
	nonLinearChirp[index] = exp(n * -2 * pi * FREQ * im)
 	global index += 1
end

# Transmission
gradient2 = (bandwidth) / (HDChirpNSamples - 1)
index2 = 1
for n in HDSamples
	PHASE = (π / HDChirpNSamples) * (n - 1) ^ 2
	HDNonLinearChirp[index2] = amplitude * ( cos(PHASE) + im * sin(PHASE) )
	global index2 += 1
end

# ====================== #
#       Plotting         #
# ====================== #

# Create figure.
fig = Figure()

# HD Linear TX Pulse.
plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 50, xRange = 2)
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="Linear Pulse")
plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0, dB = true, title="Linear Pulse PSD", xRange = 50, yRange = 40)

# HD Non Linear TX Pulse.
plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 50, xRange = 2)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDNonLinearChirp, [2,1], HDSamplingFreq, title="Non Linear Pulse")
plotPowerSpectra(fig, HDNonLinearChirp, [2,2], HDSamplingFreq, paddingCount = 0, dB = true, title="Non Linear Pulse PSD", xRange = Inf, yRange = Inf)

# Display the figure.
display(fig)

# ====================== #
#  		   EOF	   	     #
# ====================== #
