# ----------------- #
#  I N C L U D E S  #
# ----------------- #

include("../MakieGL/MakieGL.jl")
include("../MakieGL/PlotUtilities.jl")

using DSP

# -------------- #
#  P C   P L O T #
# -------------- #

# Impulse response of the signal.
function plotMatchedFilter(fig, signal::Vector, position::Vector, fs::Number; sampleRatio::Number=1, dB::Bool=true,
							xRange::Number = Inf, yRange::Number = Inf, color = :blue, axis = true, label = "",
							secondSignal = false, nSamples = false, title="Matched Filter Response", plot::Bool = true,
							timeFromZero::Bool = false)
	
	
	nSamples = length(signal)
	odd = (nSamples%2) == 1
	waveHalf = 0
	if odd
		waveHalf = (nSamples-1)/2
	else
		waveHalf = nSamples/2
	end

	# PC the signal.
	if secondSignal == false
		response = xcorr(signal, reverse(signal))
	else
		response = pulseCompression(signal, secondSignal)
	end
	responseAbs = abs.(response)

	# Return if plot not wanted.
	if plot == false
		if dB == true
			return 20 * log10.( responseAbs./maximum(responseAbs) )
		else 
			return responseAbs
		end
	end

	# Check for axis.
	if axis == true
		ax = Nothing
	else
		ax = axis
	end

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
	
	if !timeFromZero
		time = samples .* (fs^-1) ./ 1e-6
	else
		time = (0:1:(length(samples)-1)) / fs * 1e6
	end
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
    # filterSignal = txSignal .- mean(txSignal)
    # println("TX Mean: ", mean(txSignal))
	# return xcorr(rxSignal, filterSignal)
    return xcorr(rxSignal, txSignal, padmode = :none)
end


function splitMatrix(signal, pulseLengthSamples, syncRange)

    # First sync the signal.
    # println(pulseLengthSamples)
    syncedSignal, ax = syncPulseCompressedSignal(signal, pulseLengthSamples, syncRange)

    # Now we need to create a matrix of aligned pulses.
    totalPulses = floor(Int, length(syncedSignal)/pulseLengthSamples)
    pulseMatrix = Array{Complex{Float64}}(undef, pulseLengthSamples, totalPulses)

    # Iterate for every pulse.
    for i in 1:1:totalPulses
        startIndex = trunc(Int, pulseLengthSamples * (i-1)) + 1
        endIndex = trunc(Int, startIndex + pulseLengthSamples) - 1
        pulseMatrix[:,i] = syncedSignal[startIndex:1:endIndex]
    end

    return pulseMatrix

end

# ------- #
#  E O F  #
# ------- #
