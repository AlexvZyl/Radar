# =========== #
#  S E T U P  #
# =========== #

include("../MakieGL/PlotUtilities.jl")
include("PowerSpectra.jl")
include("../WindowFunctions/Blackman.jl")
include("../WindowFunctions/Chebychev.jl")
include("Synchroniser.jl")

# ================================= #
#  D O P P L E R   F F T   P L O T  #
# ================================= #

function plotDopplerFFT(figure::Figure, signal::Vector, position::Vector,
                        syncRange::Vector, fc::Number, fs::Int32, pulseLengthSamples::Int32,
                        dBRange::Vector;
                        xRange::Number=Inf, yRange::Number = Inf,
                        axis = false, label="Doppler FFT", nWaveSamples=false,
                        plotDCBin::Bool = false, plotFreqLines::Bool = true, freqVal = 20)
    
    # Calculate the PRF.
    PRI = (pulseLengthSamples) / fs
    PRF = 1 / PRI

    # Get the Doppler FFT.
    frequencies = Any
    dopplerFFTMatrix, frequencies = dopplerFFT(signal, syncRange, pulseLengthSamples, PRF)
    
    
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

    # Create the axis.
    ax = nothing
    # If no axis was specified.
    if axis == false
        ax = Axis(figure[position[1], position[2]], xlabel = "Distance (m)", ylabel = "Velocity (m/s)", title = label)
        plotOrigin(ax)
    # If an axis has been specified.
    else
        ax = axis
    end

    # Plot heatmap with dB scale.
    dopplerFFTMatrix = 20 * log10.(dopplerFFTMatrix) 
    hm = heatmap!(figure[position[1], position[2]], 
                  rangeVector, velocityVector, dopplerFFTMatrix,
                  colorrange = dBRange)

    # Plot velocities.
    if plotFreqLines
        println("Doppler FFT Freq Line Increments: ", freqVal, " Hz")
        λ = c / fc
        freqIncrement = freqVal * λ / 2 # Hz
        hValue = freqIncrement
        while(hValue < yRange )
            # hlines!(ax, hValue, color = :grey60, linewidth=0.5)
            # hlines!(ax, -hValue, color = :grey60, linewidth=0.5)
            hlines!(ax, hValue, color = :red, linewidth=1.5)
            hlines!(ax, -hValue, color = :red, linewidth=1.5)
            hValue += freqIncrement
        end
    end
                
    # For some reason this is giving me issues, not really sure why...
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

    # ------------- #
    #  D C   B I N  #
    # ------------- #

    if plotDCBin

        # # DC Bin.
        # dcAxis = Axis(figure[position[1]+1, :], xlabel = "Distance (m)", ylabel = "Magnitude (dB)", title = "DC Bin (0 m/s)",
        #           xgridvisible = false)
        # plotOrigin(dcAxis)
        # velocitiesLength = length(dopplerFFTMatrix[1,:])
        # dcBin = 0
        # odd = (velocitiesLength%2 == 1)
        # if odd 
        #     dcBin = ceil(Int, velocitiesLength/2)
        # else
        #     dcBin = floor(Int, velocitiesLength/2)
        # end
        # bin = dopplerFFTMatrix[:,dcBin]
        # scatterlines!(rangeVector, dopplerFFTMatrix[:,dcBin], markersize = dotSize, linewidth = lineThickness)
        # ylims!(0, 130)


        # Middle range line.
        dcAxis = Axis(figure[position[1]+1, :], xlabel = "Velocity (m/s)", ylabel = "Magnitude (dB)", title = "Middle Range Line",
                      xgridvisible = false)
        plotOrigin(dcAxis)
        middle = length(dopplerFFTMatrix[:,1]/2)
        middleLine = dopplerFFTMatrix[middle,:]
        scatterlines!(velocityVector, middleLine, markersize = dotSize, linewidth = lineThickness)
        # ylims!(0, 120)
        xlims!(-yRange, yRange)

    end

end

# =============================================== #
#  D O P P L E R   F F T   C A L C U L A T I O N  #
# =============================================== #

# Calculate the Doppler FFT of the given signal.
# Will most likely be a pulse compressed signal that is passed.
function dopplerFFT(signal::Vector, syncRange::Vector, pulseLengthSamples::Int32, PRF::Number)

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

    # Now take the fft over the samples.
    frequencies = Any
    fftMatrix = Array{Float64}(undef, pulseLengthSamples, totalPulses)
    # Make this call to get the frequencies for the window.
    ans, frequencies, dcComplex = powerSpectra(pulseMatrix[1,:], PRF, true)
    # window = generateChebychevWindow(frequencies, -50)
    window = kaiser((length(pulseMatrix[1,:])), 3)
    for s in 1:1:pulseLengthSamples
        pulseMatrix[s,:] .*= window
        fftMatrix[s,:], null = powerSpectra(pulseMatrix[s,:], PRF, false)
    end

    windowSum = sum(window)
    dcTot = dcComplex / windowSum
    println(dcTot)

    return fftMatrix, frequencies

end

# ======= #
#  E O F  #
# ======= #
