# ====================== #
#       Includes 		 #
# ====================== #

# File used to be able to have the same linearChirpform description
# in all of the different scripts.
include("WaveFormData.jl")
include("Utilities.jl")
include("NLFM.jl")

# For LPF
using DSP

# Plotting options.
individual = true
overlay = ! individual
HD = true

# ====================== #
#     Linear Chirp       #
# ====================== #

linearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

# Linear Waveform generation.
# gradient = (bandwidth) / (chirpNSamples - 1)
# index = 1
# for n in samples
# 	FREQ = ((gradient * (index-1)) - (bandwidth/2))/samplingFreq
# 	linearChirp[index] = exp(n * -2 * pi * FREQ * im)
#  	global index += 1
# end

# HD Linear Waveform generation.
gradient2 = (bandwidth) / (HDChirpNSamples - 1)
index2 = 1
for n in HDSamples
	FREQ = (((gradient2 * (index2-1)) - (bandwidth/2))/HDSamplingFreq)
	HDLinearChirp[index2] = exp(n * 2 * pi * FREQ * im)
	global index2 += 1
end

# ====================== #
#   Non Linear Chirp     #
# ====================== #

# Transmission interval.
tᵢ = HDChirpNSamples / HDSamplingFreq
# Signal.
signal(t; fc = 0) = exp(im*2π*(fc * t + Φ(t, tᵢ)*bandwidth))
# Time steps, given the smaples.
t = range(0, tᵢ, step = inv(HDSamplingFreq))

# Arrays containing data.
nonLinearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDNonLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

# Non Linear Waveform Generation.
# index = 1
# for n in samples
# 	PHASE = Φ(n / samplingFreq)
# 	nonLinearChirp[index] = amplitude * ( cos(PHASE) + im * sin(PHASE) )
#  	global index += 1
# end

# HD Non Linear Waveform generation.
index = 1
for n in HDSamples
	HDNonLinearChirp[index] = signal(t[index])
	global index += 1
end

LPF = digitalfilter(Lowpass(samplingFreq/2.1, fs = samplingFreq), Butterworth(10))
HDNonLinearChirp = filt(LPF, HDNonLinearChirp)

# To see what the signal is actually going to look like we need
# to pass it through a filter.

# ====================== #
#       Plotting         #
# ====================== #

# --------------------- #
#  I N D I V I D U A L  #
# --------------------- #

if individual
# Create figure.
fig = Figure()
# HD Linear TX Pulse.
plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 70, xRange = 0.66)
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="Linear Pulse")
plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0,
				 dB = true, title="Linear Pulse PSD", xRange = 200, yRange = 40)
# HD Non Linear TX Pulse.
plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 70, xRange = 0.66)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDNonLinearChirp, [2,1], HDSamplingFreq, title="Non Linear Pulse")
plotPowerSpectra(fig, HDNonLinearChirp, [2,2], HDSamplingFreq, paddingCount = 0,
			     dB = true, title="Non Linear Pulse PSD", xRange = 200, yRange = 40)
# Display the figure.
display(fig)
end

# --------------- #
#  O V E R L A Y  #
# --------------- #

if overlay
# Create figure.
fig = Figure()
# Plot the mathed filter.
ax = plotMatchedFilter(fig, HDLinearChirp, [1,2], HDSamplingFreq, label = "LFM")
plotMatchedFilter(fig, HDNonLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 70, xRange = 0.66, color = :orange, axis = ax, label = "NLFM")
axislegend(ax)
# Add zeros for the time the radar is not transmitting.
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
# PLot ther PSD's.
ax = plotPowerSpectra(fig, HDLinearChirp, [1,1], HDSamplingFreq, paddingCount = 0,
					  label = "LFM")
plotPowerSpectra(fig, HDNonLinearChirp, [1,1], HDSamplingFreq, paddingCount = 0,
				 dB = true, title="PSD", xRange = 200, yRange = 50, color = :orange,
				 axis = ax, label = "NLFM")
axislegend(ax)
# Display the figure.
display(fig)
end

# ====================== #
#  		   EOF	   	     #
# ====================== #
