# ====================== #
#       Includes 		 #
# ====================== #

# File used to be able to have the same linearChirpform description
# in all of the different scripts.
include("WaveFormData.jl")

# Plotting options.
individual = false
# Set overlay option.
if individual overlay = false
else overlay = true
end

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
	local FREQ = (((gradient2 * (index2-1)) - (bandwidth/2))/HDSamplingFreq)
	HDLinearChirp[index2] = exp(n * 2 * pi * FREQ * im)
	global index2 += 1
end

# ====================== #
#   Non Linear Chirp     #
# ====================== #

 # Δ desribes the side lobes level.
 # Higher value = smaller sidelobes.
 # Higher sidelobes lead to broader main lobe.
Δ = 50e6
# Describes the main lobe width.
# Not used in the phase equation, but shows what
# happens to the main lobe.
B = ( 2Δ * sqrt( Δ^2 + 4 ) ) / ( Δ^2 + 4 )

# Phase, given the time.
function Φ(t)
	# Transmission interval.
	tᵢ = HDChirpNSamples / HDSamplingFreq
	α = ( tᵢ * sqrt(Δ^2 + 4) ) / (2 * Δ)
	β = ( tᵢ^2 * ( Δ^2 + 4 ) ) / ( 4 * Δ^2 )
	γ = ( t - tᵢ/2 ) ^ 2
	α - sqrt(β - γ)
end

# Signal.
signal(t) = exp(im * 2π * Φ(t) * bandwidth)
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
HDNonLinearChirp = signal.(t)


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
plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 60, xRange = 4)
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="Linear Pulse")
plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0,
				 dB = true, title="Linear Pulse PSD", xRange = 50, yRange = 40)
# HD Non Linear TX Pulse.
plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 60, xRange = 4)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDNonLinearChirp, [2,1], HDSamplingFreq, title="Non Linear Pulse")
plotPowerSpectra(fig, HDNonLinearChirp, [2,2], HDSamplingFreq, paddingCount = 0,
			     dB = true, title="Non Linear Pulse PSD", xRange = 50, yRange = 40)
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
ax = plotMatchedFilter(fig, HDLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 60, xRange = 4, label = "LFM")
plotMatchedFilter(fig, HDNonLinearChirp, [1,2], HDSamplingFreq, dB = true, yRange = 60, xRange = 4, color = :orange, axis = ax, label = "NLFM")
# axislegend(ax)
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
end

# ====================== #
# ====================== #
#  		   EOF	   	     #
