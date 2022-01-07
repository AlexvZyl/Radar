# ====================== #
#       Includes 		 #
# ====================== #

# File used to be able to have the same linearChirpform description
# in all of the different scripts.
include("WaveFormData.jl")

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

# Phase calculations.
# x = 2
# B = min(sqrt(x), 1.989)
# Δ = 2 * B / sqrt(4 - B^2)  # Total change in instantaneous frequency.

Δ = 2 #  Desribes the side lobes level.
B = ( 2Δ * sqrt( Δ^2 + 4 ) ) / ( Δ^2 + 4 )  #  Describes the main lobe width.

t_i = HDChirpNSamples / HDSamplingFreq
function Φ(t)  #  Phase.
	α = t_i * sqrt(Δ^2 + 4)/(2 * Δ)
	(α - sqrt(α^2 - (t - t_i/2)^2))/Δ
end

# Signal.
s(t; fc = 0) = exp(im*2π*(fc * t + Φ(t)*bandwidth))
signal(t) = s(t, fc = 0)
t = range(0, t_i, step = inv(HDSamplingFreq))

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

# ====================== #
#       Plotting         #
# ====================== #

# # Create figure.
# fig = Figure()
#
# # HD Linear TX Pulse.
# plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 40, xRange = 4)
# # plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 50, xRange = Inf)
# addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
# plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="Linear Pulse")
# plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0,
# 				 dB = true, title="Linear Pulse PSD", xRange = 50, yRange = 40)
#
# # HD Non Linear TX Pulse.
# plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 40, xRange = 4)
# # plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 50, xRange = Inf)
# addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
# plotSignal(fig, HDNonLinearChirp, [2,1], HDSamplingFreq, title="Non Linear Pulse")
# plotPowerSpectra(fig, HDNonLinearChirp, [2,2], HDSamplingFreq, paddingCount = 0,
# 			     dB = true, title="Non Linear Pulse PSD", xRange = 50, yRange = 40)
#
# # Display the figure.
# display(fig)

# Create figure.
fig = Figure()

# plotMatchedFilter(fig, HDLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 40, xRange = 4)
# plotMatchedFilter(fig, HDNonLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 40, xRange = 4, color = :orange, newAxis = false)


# Plot the mathed filter.
ax = plotMatchedFilter(fig, HDLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 50, xRange = 5, label = "LFM")
plotMatchedFilter(fig, HDNonLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 50, xRange = 5, color = :orange, axis = ax, label = "NLFM")
axislegend(ax)

# Add zeros for the time the radar is not transmitting.
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)

# PLot ther PSD's.
ax = plotPowerSpectra(fig, HDLinearChirp, [1,1], HDSamplingFreq, paddingCount = 0,
					  dB = true, title="PSD", xRange = 50, yRange = 40,
					  label = "LFM")
plotPowerSpectra(fig, HDNonLinearChirp, [1,1], HDSamplingFreq, paddingCount = 0,
				 dB = true, title="PSD", xRange = 50, yRange = 40, color = :orange,
				 axis = ax, label = "NLFM")
axislegend(ax)

# Display the figure.
display(fig)

# ====================== #
#  		   EOF	   	     #
# ====================== #
