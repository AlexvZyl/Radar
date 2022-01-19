# Makie utilities.
include("../../Utilities/MakieGL.jl")

using FFTW
using DSP

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

# ------------- #
#  S I G N A L  #
# ------------- #

# Plot the comples signal.
function plotSignal(fig::Figure, signal::Vector, position::Vector, fs::Number;
					sampleRatio::Number = 1, title::String = "Signal")
	# Reduce the amount of samples to be plotted.
	IchannelScaled = real(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	QchannelScaled = imag(signal)[1:1:trunc(Int, length(signal)*sampleRatio)]
	signalTot = IchannelScaled + im * QchannelScaled
	# Signal axis.
	ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = title,
	          titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	# Plot the origin.
	plotOrigin(ax)
	# Signal.
	samples = 0:1:length(IchannelScaled)-1
	time = samples .* (fs^-1) ./ 1e-6
	plotQLines = lines!(time, abs.(signalTot), color = :red, linewidth = lineThickness, label = "Envelope")
	plotQScat = scatter!(time, abs.(signalTot), color = :red, markersize = dotSize)
	plotQLines = lines!(time, QchannelScaled, color = :orange, linewidth = lineThickness, label = "Q Channel")
	plotQScat = scatter!(time, QchannelScaled, color = :orange, markersize = dotSize)
	plotILines = lines!(time, IchannelScaled, color = :blue, linewidth = lineThickness, label = "I Channel")
	plotIScat = scatter!(time, IchannelScaled, color = :blue, markersize = dotSize)
	xlims!(0, time[end])
	# Add legend.
	axislegend(ax)
end

# ------- #
#  F F T  #
# ------- #

function plotFFT(fig::Figure, signal::Vector, position::Vector;
				 paddingCount::Number=0, sampleRatio::Number=1, dB::Bool=true, title::String = "FFT",
				 color = :blue, axis = true)
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
		if axis == true
			ax = Axis(fig[position[1], position[2]], xlabel = "k", ylabel = "Magnitude (dB)", title = title,
				  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
		   	plotOrigin(ax)
	  	end
	else
		if axis == true
			ax = Axis(fig[position[1], position[2]], xlabel = "k", ylabel = "Amplitude", title = title,
					  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	  	    plotOrigin(ax)
	    end
	end
	# Plot the FFT.
	fftStep = 1/((length(FFT)))
	samplesNormalized = 0:fftStep:1-fftStep
	lines!(samplesNormalized, FFT, color = color, linewidth = lineThickness)
	scatter!(samplesNormalized, FFT, color = color, markersize = dotSize)
	return axis
end

# ----------------------------- #
#  M A T C H E D   F I L T E R  #
# ----------------------------- #

# Impulse response of the signal.
function plotMatchedFilter(fig::Figure, signal::Vector, position::Vector, fs::Number; sampleRatio::Number=1, dB::Bool=true,
							xRange::Number = Inf, yRange::Number = Inf, color = :blue, axis = true, label = "",
							secondSignal = false, nSamples = false)
	ax = nothing

	# Matched filter response.
	if secondSignal != false
		response = xcorr(signal, secondSignal)
	else
		response = xcorr(signal, signal)
	end
	responseReal = real(response)
	responseImag = imag(response)
	responseAbs = abs.(response)
	# Create DB axis.
	if dB
		responseReal = real( 20 * log10.(Complex.(responseReal)./maximum(responseReal)) )
		responseImag = imag( 20 * log10.(Complex.(responseImag)./maximum(responseImag)) )
		responseAbs = 20 * log10.( responseAbs./maximum(responseAbs) )
		# Axis.
		if axis == true
			ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Magnitude (dB)", title = "Matched Filter Response",
					  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
		  	plotOrigin(ax)
	  	end

	# Create non DB axis.
	else
		if axis == true
			ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = "Matched Filter Response",
					  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
		  	plotOrigin(ax)
	  	end
	end

	# Plot the response.

	if (length(responseReal) % 2 == 1)
		samples = -floor(Int, length(responseReal)/2):1:floor(Int, length(responseReal)/2)
	else
		samples = -floor(Int, length(responseReal)/2):1:floor(Int, length(responseReal)/2)-1
	end
	time = samples .* (fs^-1) ./ 1e-6
	lines!(time, responseAbs, color =color,  linewidth = lineThickness, label = label)
	scatter!(time, responseAbs, color =color, markersize = dotSize)

	# Set the x range.
	if xRange != Inf
		xlims!(-xRange/2, xRange/2)
	end

	# Set the y range.
	if yRange != Inf
		if dB ylims!(-yRange, 0)
		else ylims!(-yRange/2, yRange/2)
		end
	end

	# Return the axis to be used by other plots.
	return ax
end

# --------------------------- #
#  P O W E R   S P E C T R A  #
# --------------------------- #

function plotPowerSpectra(fig::Figure, signal::Vector, graphPosition::Vector, fs::Number;
						  paddingCount::Number=0, sampleRatio::Number = 1, dB::Bool = true, title::String = "Frequency Power Spectra",
						  scatterPlot::Bool = false, xRange::Number = Inf, yRange::Number = Inf, color = :blue, axis = true,
						  label = "")
	ax = nothing
	# Reduce the amount of samples to be plotted.
	signalScaled = signal[1:1:trunc(Int, length(signal)*sampleRatio)]
	# Pad the signal.
	if paddingCount != 0
		zerosVec = zeros(paddingCount) + im*zeros(paddingCount)
		append!(signalScaled, zerosVec)
	end
	# Calculate FFT.
	signalFFT = abs.(fft(real(signalScaled) + im*imag(signalScaled)))
	# Shift the FFT to display positive frequencies.
	fftLength = length(signalFFT)
	if fftLength % 2 == 1
		fftCenter = trunc(Int, (fftLength-1)/2) + 1
		fftY = signalFFT[fftCenter : end]
		append!(fftY, signalFFT[1 : fftCenter + 1])
	else
		fftCenter = trunc(Int, (fftLength)/2)
		fftY = signalFFT[fftCenter + 1 : end]
		append!(fftY, signalFFT[1 : fftCenter])
	end
	# Create dB axis.
	if dB
		fftY = 20 * log10.(fftY./maximum(fftY))
		if axis == true
			ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Magnitude (dB)", title = title,
					  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	  	  	plotOrigin(ax)
		end

	# Create non dB axis.
	else
		fftY /= fftLength
		if axis == true
			ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Amplitude", title = title,
					  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	  	  	plotOrigin(ax)
		end
	end

	# Create the frequencies vector.
	if fftLength % 2 == 1
		frequencies = collect(-fftCenter:1:0) / fftCenter * fs
		toAppend = collect(1:1:fftCenter) / fftCenter * fs
		append!(frequencies, toAppend)
		frequencies /= 4e6
	else
		frequencies = collect(-fftCenter:1:-1) / fftCenter * fs
		toAppend = collect(1:1:fftCenter) / fftCenter * fs
		append!(frequencies, toAppend)
		frequencies /= 4e6
	end

	# Plot the PSD.
	lines!(frequencies, fftY, color = color, linewidth = lineThickness, label = label)
	if scatterPlot
		scatter!(frequencies, fftY, color = color, markersize = dotSize)
	end

	# Set the X Range.
	if xRange != Inf
		xlims!(-xRange/2, xRange/2)
	end

	# Set the Y range.
	if yRange != Inf
		if dB ylims!(-yRange, 0)
		else ylims!(-yRange/2, yRange/2)
		end
	end

	# Return the axis to be used by other plots.
	return ax
end

function plotIQCircle(figure::Figure, signal::Vector, position::Vector;
					  axis::Axis=false, color=:blue, label="Signal")

  	# Setup axis.
	ax = nothing
	if axis == false
		ax = Axis(  figure[position[1], positionp[2]], xlabel = "I Channel", ylabel = "Q Channel", title = "I vs Q",
            		titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	else
		ax = axis
	end

	# Plot the IQ data.
	normFactor = maximum(max.(maximum(real(signal)), imag(signal)))
	scatter!(real(signal)/normFactor, imag(signal)/normFactor,
			 color = color, markersize = dotSize, label=label)

	 return ax
end

# ====================== #
#          EOF           #
# ====================== #
