# ----------------- #
#  I N C L U D E S  #
# ----------------- #

include("../MakieGL/MakieGL.jl")

# -------------- #
#  P C   P L O T #
# -------------- #

# Impulse response of the signal.
function plotMatchedFilter(fig::Figure, signal::Vector, position::Vector, fs::Number; sampleRatio::Number=1, dB::Bool=true,
							xRange::Number = Inf, yRange::Number = Inf, color = :blue, axis = true, label = "",
							secondSignal = false, nSamples = false, title="Matched Filter Response")
	ax = nothing

	# PC the signal.
	if secondSignal == false
		response = xcorr(signal, reverse(signal))
	else
		response = pulseCompression(signal, secondSignal)
	end
	responseAbs = abs.(response)

	# Create DB axis.
	if dB
		responseAbs = 20 * log10.( responseAbs./maximum(responseAbs) )
		# Create new axis.
		if axis == true
			ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Magnitude (dB)", title = title)
		  	plotOrigin(ax)
	  	end

	# Create new, non DB axis.
	elseif axis == true
		ax = Axis(fig[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = title)
		plotOrigin(ax)

	end

	# Plot the response.
	if (length(responseAbs) % 2 == 1)
		samples = -floor(Int, length(responseAbs)/2):1:floor(Int, length(responseAbs)/2)
	else
		samples = -floor(Int, length(responseAbs)/2):1:floor(Int, length(responseAbs)/2)-1
	end
	
	time = samples .* (fs^-1) ./ 1e-6
	# lines!(time, responseAbs, color = color,  linewidth = lineThickness, label = label)
	scatterlines!(time, responseAbs, color = color, markersize = dotSize, linewidth = lineThickness, label = label)

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
	return responseAbs, ax
end

# ----------------------------- #
#  P C   C A L C U L A T I O N  #
# ----------------------------- #

function pulseCompression(txSignal::Vector, rxSignal::Vector)

	return xcorr(txSignal, rxSignal)

end

# ------- #
#  E O F  #
# ------- #
