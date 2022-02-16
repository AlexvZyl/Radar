# Makie utilities.
include("MakieGL.jl")

using FFTW
using DSP

c = 299792458

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
	vlines!(ax, 0, color = originColor, linewidth=originThickness)
	hlines!(ax, 0, color = originColor, linewidth=originThickness)
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
	ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = title)
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



function plotIQCircle(figure::Figure, signal::Vector, position::Vector;
					  axis=false, color=:blue, label="Signal")

  	# Setup axis.
	# ax = nothing
	if axis == false
		ax = Axis(  figure[position[1], position[2]], xlabel = "I Channel", ylabel = "Q Channel", title = "I vs Q",
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
