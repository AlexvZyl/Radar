# --------------------------- #
#  S Y N C   F U N C T I O N  #
# --------------------------- #

function syncPulseCompressedSignal(signal::Vector, pulseLengthSamples::Number, syncRange::Vector;
                                    plot = false, figure = false, position::Vector = [1,1], axis = false, dB = true,
                                    timeFromZero = true, yRange = Inf, xRange = Inf, title = "Synced Matched Filter Response",
                                    color = :blue, label = "")

    # First we have to find the first peak to sync the tx & receive signal.
    toSearch = abs.(signal[syncRange[1]:1:syncRange[2]])
    peakIndex = argmax(toSearch)
    syncedSignal = signal[peakIndex:1:end]

    # The last pulse is not going to be a full pulse, so it has to be removed.
    # How many pulses fit into the signal?
    totalPulses = floor(Int32, length(syncedSignal)/pulseLengthSamples)
    # syncedSignal = abs.(syncedSignal[1:1:totalPulses*pulseLengthSamples])
    syncedSignal = syncedSignal[1:1:totalPulses*pulseLengthSamples]

    # ----------------- #
    #  P L O T T I N G  #
    # ----------------- #

    #  Create new axis.
    ax = nothing
    if axis == false && plot
        # dB.
        if dB
            syncedSignal ./= maximum(syncedSignal)
            syncedSignal = 20 * log10.(syncedSignal)
            ax = Axis(figure[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Magnitude (dB)", title = title)
        # Non-dB.
        else
            ax = Axis(figure[position[1], position[2]], xlabel = "Time (μs)", ylabel = "Amplitude", title = title)
        end
        plotOrigin(ax)
    else
        ax = axis
    end

    if plot

        # Take time from zero.
        if timeFromZero
            time = collect((0:1:(length(syncedSignal)-1)) / fs)
        end
        scatterlines!(time * 1e6, syncedSignal, color = color, markersize = dotSize, linewidth = lineThickness, label = label)

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

    end

	# Return the axis to be used by other plots.
	return syncedSignal, ax

end

# ------- #
#  E O F  #
# ------- #
