# ----------------- # 
#  I N C L U D E S  #
# ----------------- # 

include("../MakieGL/PlotUtilities.jl")

# ----------------------- #
#  P L O T   P U L S E S  #
# ----------------------- #

function plotPulseMatrix(figure::Figure, signal::Vector, position::Vector, fs::Number, 
                         pulseLengthSamples::Number, dBRange::Vector;
                         axis = false)

    #  D A T A  #
    # pulseLengthSamples -= 2
    # Create pulse data matrix.
    totalPulses = floor(Int32, length(signal)/pulseLengthSamples)
    pulsesMatrix = Array{Float32}(undef, pulseLengthSamples, totalPulses)
    
    # Fill the matrix.
    absSignal = abs.(signal)
    for p in 1:1:totalPulses
        start = ( (p-1) * pulseLengthSamples ) + 1
        pulsesMatrix[:, p] = absSignal[start:1:start+pulseLengthSamples-1]
    end

    #  P L O T  #

    # Create a time vector.
    time = (0:1:pulseLengthSamples-1)/fs
    # Create a pulses count vector.
    pulses = 0:1:totalPulses-1
    # Range vector
    rangeVector = (   0:1:pulseLengthSamples-1     ) / fs / 2 * c

    # Axis.
    ax = nothing
    # Create a new axis.
    if axis == false
        ax = Axis(figure[position[1], position[2]], xlabel = "Distance (m)", ylabel = "Pusles", title = "Received Pulses",
                  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
        plotOrigin(ax)
    # Use the passed axis.
    else
        ax = axis
    end

    # pulsesMatrix[1,1] += 1000

    # Plot heatmap with dB scale.
    hm = heatmap!(figure[position[1], position[2]], 
                  rangeVector, pulses, pulsesMatrix,
                  colorrange = dBRange)

    # Plot the colorbar.
    cbar = Colorbar(figure[position[1], position[2]+1], label="Amplitude (dB)", hm)

    # Return the axis to be used by other plots.
    return ax

end

# ------- #
#  E O F  #
# ------- #