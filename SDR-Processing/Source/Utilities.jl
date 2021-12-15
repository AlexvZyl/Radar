# ====================== #
#        Modules         #
# ====================== #

using GLMakie
using FFTW
using DSP
set_theme!(theme_dark())
update_theme!(
	Axis = (
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :gray90,
    	topspinecolor = :gray90,
    	leftspinecolor = :gray90,
    	rightspinecolor = :gray90
		),
	Legend = (
		# framevisible = true,
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :gray90,
    	topspinecolor = :gray90,
    	leftspinecolor = :gray90,
    	rightspinecolor = :gray90,
		backgroundcolor = :gray90,
		)
	)
# Graph parameters.
textSize = 23
lineThickness = 4
dashThickness = 2.5
dotSize = 8
originThickness = 2

# ====================== #
#       Constants        #
# ====================== #

const c = 299792458

# ====================== #
#    Parameters          #
# ====================== #

txDuration   	= 1
amplitude    	= 1
samplingFreq 	= 12e6
deadZone     	= 1000
maxRange     	= 1500
HDFreq  	= 900e6

# ====================== #
#         Wave           #
# ====================== #

# -------------------
# TX Pulse
# -------------------
# Derived.
bandwidth 				= samplingFreq / 2.1
# bandwidth 				= 16e6/2.1
chirpNSamples 			= round(Int, (deadZone / c) * samplingFreq)
if (chirpNSamples%2==0)	chirpNSamples += 1 end
pulseNSamples 			= round(Int, (maxRange / c) * samplingFreq)
if (pulseNSamples%2==0) pulseNSamples += 1 end
pulsesPerTransmission 	= round(Int, (txDuration * samplingFreq)/pulseNSamples)
samples 			    = floor(-(chirpNSamples-1)/2):floor(((chirpNSamples-1)/2))
pulseSamples 			= floor(-(pulseNSamples-1)/2):floor(((pulseNSamples-1)/2))

# -------------------
# HD TX Pulse
# -------------------
HDSamplingFreq 	       = samplingFreq * 1000
HDChirpNSamples 	   = round(Int, (deadZone / c) * HDSamplingFreq)
if (HDChirpNSamples%2==0)
						chirpNSamples += 1 end
HDPulseNSamples	       = round(Int, (maxRange / c) * HDSamplingFreq)
if (HDPulseNSamples%2==0)
						chirpNSamples += 1 end
HSamples 	           = floor(-(HDChirpNSamples-1)/2):floor(((HDChirpNSamples-1)/2))
HDPulseSamples 	       = floor(-(HDPulseNSamples-1)/2):floor(((HDPulseNSamples-1)/2))

# ====================== #
#       Functions        #
# ====================== #

# Add zeros to the end of the linearChirp.
function addZeros!(linearChirp::Vector, Zeros::Number)
    zerosVec = zeros(Zeros) + im*zeros(Zeros)
    linearChirp = append!(linearChirp, zerosVec)
end
function addZeros(linearChirp::Vector, Zeros::Number)
    zerosVec = zeros(Zeros) + im*zeros(Zeros)
    append(linearChirp, zerosVec)
end

# Plot the origin on the graph.
function plotOrigin(ax::Axis)
	vlines!(ax, 0, color = :white, linewidth=originThickness)
	hlines!(ax, 0, color = :white, linewidth=originThickness)
end

# Plot the comples signal.
function plotSignal(fig::Figure, signal::Vector, position::Vector, fs::Number;
					sampleRatio::Number = 1, title::String = "Signal")
	# Reduce the amount of samples to be plotted.
	IchannelScaled = real(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	QchannelScaled = imag(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	# Signal axis.
	ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = title,
	          titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	# Plot the origin.
	plotOrigin(ax)
	# Signal.
	samples = 0:1:length(IchannelScaled)-1
	time = samples .* (fs^-1) ./ 1e-6
	plotILines = lines!(time, IchannelScaled, color = :blue, linewidth = lineThickness, label = "I Channel")
	plotIScat = scatter!(time, IchannelScaled, color = :blue, markersize = dotSize)
	plotQLines = lines!(time, QchannelScaled, color = :orange, linewidth = lineThickness, label = "Q Channel")
	plotQScat = scatter!(time, QchannelScaled, color = :orange, markersize = dotSize)
	xlims!(0, time[end])
	# Add legend.
	axislegend(ax)
end

function plotFFT(fig::Figure, signal::Vector, position::Vector;
				 paddingCount::Number=0, sampleRatio::Number=1, dB::Bool=true, title::String = "FFT")
	# Reduce the amount of samples to be plotted.
	IchannelScaled = real(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	QchannelScaled = imag(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	# Zero padding.
	zerosArray = zeros(paddingCount)
	append!(IchannelScaled, zerosArray)
	append!(QchannelScaled, zerosArray)
	FFT = abs.(fft(IchannelScaled + QchannelScaled*im))
	if dB
		FFT = 20 * log10.(FFT./maximum(FFT))
		ax = Axis(fig[position[1], position[2]], xlabel = "k", ylabel = "Magnitude (dB)", title = title,
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	else
		ax = Axis(fig[position[1], position[2]], xlabel = "k", ylabel = "Amplitude", title = title,
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	end
	# Plot the origin.
	plotOrigin(ax)
	# Plot the FFT.
	samplesNormalized = 0:1/((length(FFT))-1):1
	lines!(samplesNormalized, FFT, color = :blue, linewidth = lineThickness)
	scatter!(samplesNormalized, FFT, color = :blue, markersize = dotSize)
	return FFT
end

# Impulse response of the signal.
function plotMatchedFilter(fig::Figure, signal::Vector, position::Vector, fs::Number; sampleratio::Number=1, dB::Bool=true,
							xRange::Number = Inf, yRange::Number = Inf)
	# Matched filter response.
	response = xcorr(signal, signal)
	responseReal = real(response)
	responseImag = imag(response)
	# Create axis based on dB.
	if dB
		responseReal = real( 20 * log10.(Complex.(responseReal)./maximum(responseReal)) )
		responseImag = imag( 20 * log10.(Complex.(responseImag)./maximum(responseImag)) )
		# responseImag = real(20 * log10.(responseImag./maximum(responseImag)))
		ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Magnitude (dB)", title = "Matched Filter Response",
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	else
		ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = "Matched Filter Response",
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	end
	# Plot the origin.
	response = responseReal + im * responseImag
	plotOrigin(ax)
	# Plot the response.
	samples = -length(responseReal)/2:1:length(responseReal)/2-1
	time = samples .* (fs^-1) ./ 1e-6
	lines!(time, responseReal, color = :blue, linewidth = lineThickness)
	scatter!(time, responseReal, color = :blue, markersize = dotSize)
	# Set limits.
	if xRange != Inf
		xlims!(-xRange/2, xRange/2)
	end
	if yRange != Inf
		if dB ylims!(-yRange, 0)
		else ylims!(-yRange/2, yRange/2)
		end
	end
	return response
end

function plotPowerSpectra(fig::Figure, signal::Vector, graphPosition::Vector, fs::Number;
						  paddingCount::Number=0, sampleRatio::Number = 1, dB::Bool = true, title::String = "Frequency Power Spectra",
						  scatterPlot::Bool = false, xRange::Number = Inf, yRange::Number = Inf)
	# Reduce the amount of samples to be plotted.
	signalScaled = signal[1:1:trunc(Int, length(signal)*sampleRatio)]
	# Pad the signal.
	zerosVec = zeros(paddingCount) + im*zeros(paddingCount)
	append!(signalScaled, zerosVec)
	# Calculate FFT.
	signalFFT = abs.(fft(real(signalScaled) + im*imag(signalScaled)))
	# Shift the FFT to display positive frequencies.
	fftLength = length(signalFFT)
	fftY = signalFFT[ceil(Int, fftLength/2):end]
	append!(fftY, signalFFT[1:ceil(Int, fftLength/2)])
	# Create axis based on dB.
	if dB
		fftY = 20 * log10.(fftY./maximum(fftY))
		ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Magnitude (dB)", title = title,
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	else
		fftY /= fftLength
		ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Amplitude", title = title,
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	end
	# Plot the origin.
	plotOrigin(ax)
	# PLot the spectra.
	samplesNormalized = 0:1/((length(fftY))-1):1
	frequencies = (-fs/2:fs/fftLength:fs/2) / 1e6
	lines!(frequencies, fftY, color = :blue, linewidth = lineThickness)
	if scatterPlot scatter!(samplesNormalized, fftY, color = :blue, markersize = dotSize) end
	# Set limits.
	if xRange != Inf
		xlims!(-xRange/2, xRange/2)
	end
	if yRange != Inf
		if dB ylims!(-yRange, 0)
		else ylims!(-yRange/2, yRange/2)
		end
	end

	return signalFFT
end

function mixSignal(Signal1::Vector, Signal2::Vector)

end

# ====================== #
#          EOF           #
# ====================== #
