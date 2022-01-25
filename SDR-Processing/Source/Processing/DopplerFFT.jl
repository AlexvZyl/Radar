# =========== #
#  S E T U P  #
# =========== #

include("../PlotUtilities.jl")
include("PowerSpectra.jl")
include("../WindowFunctions/Blackman.jl")
include("../WindowFunctions/Chebychev.jl")

# Testing.
# using Plots
# gr()

# ================================= #
#  D O P P L E R   F F T   P L O T  #
# ================================= #

function plotDopplerFFT(figure::Figure, signal::Vector, position::Vector,
                        syncRange::Vector, fc::Number, fs::Int32, pulseLengthSamples::Int32,
                        dBRange::Vector;
                        xRange::Number=Inf, yRange::Number = Inf,
                        axis = false, label="Doppler FFT", nWaveSamples=false)
    
    # Calculate the PRF.
    pulseTime = pulseLengthSamples / fs
    PRF = 1 / pulseTime

    # Get the Doppler FFT.
    frequencies = Any
    dopplerFFTMatrix, frequencies = dopplerFFT(signal, syncRange, pulseLengthSamples, PRF)

    # Create the axis.
    ax = nothing
    # If no axis was specified.
    if axis == false
        ax = Axis(figure[position[1], position[2]], xlabel = "Distance (m)", ylabel = "Velocity (m/s)", title = label,
                  titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
        plotOrigin(ax)
    # If an axis has been specified.
    else
        ax = axis
    end

    # ------------------------- #
    #  R A N G E   V E C T O R  #
    # ------------------------- #

    # Range vector.
    rangeLength = trunc(Int32, length(dopplerFFTMatrix[:,1]))
    if rangeLength %2 == 1
        rangeVector = (   0:1:rangeLength     ) / fs / 2 * c
    else
        # The offset of 0.5 is there to ensure the bin starts at 0,
        # and not have it sit around 0.
        rangeVector = ( 0.5:1:rangeLength-0.5 ) / fs / 2 * c
    end
    
    # Range data reduction.
    if xRange != Inf

        # Find the sample value that has to been plotted to.
        rangeSample = ceil(Int32, (xRange / c) * 2 * fs)
        if rangeSample < length(rangeVector)
            rangeVector = rangeVector[1:1:rangeSample]
            dopplerFFTMatrix = dopplerFFTMatrix[1:1:rangeSample, :]        
        end

    end

    # ------------------------------- #
    #  V E L O C I T Y   V E C T O R  #
    # ------------------------------- #

    # Is the vector odd?
    odd = (length(frequencies)%2 == 1)

    # Calculate the velocities.
    λ = c / fc
    velocityVector =  ( frequencies * λ ) / 2
    
    # Velocity data reduction.
    if yRange != Inf

        # Find the sample value that has to been plotted to.
        if odd
            velocityCenterSample = ceil(Int32, length(velocityVector)/2)
        else
            velocityCenterSample = floor(Int32, length(velocityVector)/2)
        end

        # The frequency where the sample sits.
        velocitySample = ceil(Int32, length(velocityVector)/2 * ( yRange / maximum(velocityVector)))

        # Reduce the data to be plotted.
        if velocitySample < velocityCenterSample 
            if odd
                velocityVector = velocityVector[velocityCenterSample-velocitySample+1:1:velocityCenterSample+velocitySample-1]
                dopplerFFTMatrix = dopplerFFTMatrix[:, velocityCenterSample-velocitySample+1:1:velocityCenterSample+velocitySample-1]
            else
                velocityVector = velocityVector[velocityCenterSample-velocitySample:1:velocityCenterSample+velocitySample+1]
                dopplerFFTMatrix = dopplerFFTMatrix[:, velocityCenterSample-velocitySample:1:velocityCenterSample+velocitySample+1]
            end
        end

    end

    # ----------------- #
    #  P L O T T I N G  #
    # ----------------- #
    
    # Plot heatmap with dB scale.
    dopplerFFTMatrix = 20 * log10.(dopplerFFTMatrix) 
    hm = heatmap!(figure[position[1], position[2]], 
                  rangeVector, velocityVector, dopplerFFTMatrix,
                  colorrange = dBRange)# colormap = :afmhot)

    # heatmap(rangeVector, velocityVector, dopplerFFTMatrix)

    # Plot the colorbar.
    # cbar = Colorbar(figure[position[1], position[2]+1], label="Amplitude (dB)", hm)

    # Plot a line at the deadzone.
    if nWaveSamples != false
        deadZoneRange = (nWaveSamples / (2 * fs) ) * c
        vlines!(ax, deadZoneRange, color=:cyan, linewidth = 3.5, label="Deadzone")
        if axis == false
            axislegend(ax)
        end
    end 

    # Set the X Range.
    if xRange != Inf
        xlims!(0, ((rangeSample-1)*c)/(fs * 2))
    end

    # Set the Y range.
    if yRange != Inf
        ylims!(-yRange, yRange)
    end

end

# =============================================== #
#  D O P P L E R   F F T   C A L C U L A T I O N  #
# =============================================== #

# Calculate the Doppler FFT of the given signal.
# Will most likely be a pulse compressed signal that is passed.
function dopplerFFT(signal::Vector, syncRange::Vector, pulseLengthSamples::Int32, PRF::Number)

    # First we have to find the first peak to sync the tx & receive signal.
    toSearch = abs.(signal[syncRange[1]:1:syncRange[2]])
    peakIndex = argmax(toSearch)
    syncedSignal = signal[peakIndex:1:end]

    # Now we need to create a matrix of aligned pulses.
    totalPulses = floor(Int, length(syncedSignal)/pulseLengthSamples)
    pulseMatrix = Array{Complex{Float32}}(undef, pulseLengthSamples, totalPulses)

    # Iterate for every pulse.
    for i in 1:1:totalPulses
        startIndex = trunc(Int, pulseLengthSamples * (i-1)) + 1
        endIndex = trunc(Int, startIndex + pulseLengthSamples) - 1
        pulseMatrix[:,i] = syncedSignal[startIndex:1:endIndex]
    end

    # Now take the fft over the pulses.
    frequencies = Any
    fftMatrix = Array{Float32}(undef, pulseLengthSamples, totalPulses)
    # Make this call to get the frequencies for the window.
    ans, frequencies = powerSpectra(pulseMatrix[1,:], PRF, true)
    # window = generateChebychevWindow(frequencies, -50)
    window = kaiser((length(pulseMatrix[1,:])), 3)
    for s in 1:1:pulseLengthSamples
        pulseMatrix[s,:] .*= window
        fftMatrix[s,:] = powerSpectra(pulseMatrix[s,:], PRF, false)
    end
    
    return fftMatrix, frequencies

end

# ======= #
#  E O F  #
# ======= #
