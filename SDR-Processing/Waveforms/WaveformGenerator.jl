# ====================== #
#       Includes 		 #
# ====================== #

# File used to be able to have the same linearChirpform description
# in all of the different scripts.
include("WaveFormData.jl")
include("../PlotUtilities.jl")
include("NLFM.jl")

# For LPF
using DSP

# ====================== #
#     Linear Chirp       #
# ====================== #

linearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

# HD Linear Waveform generation.
gradient2 = (bandwidth) / (HDChirpNSamples - 1)
index2 = 1
for n in HDSamples
	linearFREQ = (((gradient2 * (index2-1)) - (bandwidth/2))/HDSamplingFreq)
	HDLinearChirp[index2] = exp(n * 2 * pi * linearFREQ * im)
	global index2 += 1
end

# ====================== #
#   Non Linear Chirp     #
# ====================== #

# Transmission interval.
tᵢ = (HDChirpNSamples+1) / HDSamplingFreq
# Time steps, given the smaples.
timePositive = collect((1:1:HDChirpNSamples)) / HDSamplingFreq

# Arrays containing data.
nonLinearChirp = Array{Complex{Float32}}(undef, chirpNSamples)
HDNonLinearChirp = Array{Complex{Float32}}(undef, HDChirpNSamples)

# ------------------- #
#  F R E Q U E N C Y  #
# ------------------- #

FREQ = fᵢ.(timePositive, tᵢ, bandwidth)
FREQ *= 1e6
display(FREQ)
offset = (HDChirpNSamples-1) / 2
for i in 0:1:HDChirpNSamples-1
	n = i - offset
	local k = (n * FREQ[i+1]) / samplingFreq
	HDNonLinearChirp[i+1] = exp(2 * pi * im * k)
end

# Plot NLFM.
figure = Figure()
axis = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "NLFM",
       titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
plotOrigin(axis)
scatter!(timePositive*1e6, FREQ/1e6, color = :blue, linewidth = lineThickness, label = "Frequency")
display(figure)

# ====================== #
#       Plotting         #
# ====================== #

# Plotting options.
individual = false
individual = true
overlay = ! individual
overlay = false

#  I N D I V I D U A L  #
# --------------------- #
# --------------------- #

if individual

# Create figure.
fig = Figure()
# HD Linear TX Pulse.
plotMatchedFilter(fig, HDLinearChirp, [1,3], HDSamplingFreq, dB = true, yRange = 70, xRange = 0.66)
addZeros!(HDLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDLinearChirp, [1,1], HDSamplingFreq, title="Linear Pulse")
plotPowerSpectra(fig, HDLinearChirp, [1,2], HDSamplingFreq, paddingCount = 0,
				 dB = true, title="Linear Pulse PSD", xRange = HDSamplingFreq/2e6, yRange = 40)
# HD Non Linear TX Pulse.
plotMatchedFilter(fig, HDNonLinearChirp, [2,3], HDSamplingFreq, dB = true, yRange = 70, xRange = 0.66)
addZeros!(HDNonLinearChirp, HDPulseNSamples-HDChirpNSamples)
plotSignal(fig, HDNonLinearChirp, [2,1], HDSamplingFreq, title="Non Linear Pulse")
plotPowerSpectra(fig, HDNonLinearChirp, [2,2], HDSamplingFreq, paddingCount = 0,
dB = true, title="Non Linear Pulse PSD", xRange = HDSamplingFreq/2e6, yRange = 40)
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
