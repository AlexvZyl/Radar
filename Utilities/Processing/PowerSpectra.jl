# ----------------- # 
#  I N C L U D E S  #
# ----------------- # 

include("../MakieGL/PlotUtilities.jl")

# ------------------------------------- #
#  P O W E R   S P E C T R A   P L O T  #
# ------------------------------------- #

function plotPowerSpectra(fig::Figure, signal::Vector, graphPosition::Vector, fs::Number;
                          paddingCount::Number=0, sampleRatio::Number = 1, dB::Bool = true, title::String = "Frequency Power Spectra",
                          scatterPlot::Bool = false, xRange::Number = Inf, yRange::Number = Inf, color = :blue, axis = true,
                          label = "")
    
    ax = nothing

    fftY, frequencies = powerSpectra(signal, fs, true, paddingCount=paddingCount)

    # Create dB axis.
    if dB
        fftY = 20 * log10.(fftY./maximum(fftY))
        if axis == true
            ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Magnitude (dB)", title = title)
            plotOrigin(ax)
        end

        # Create non dB axis.
        else
            fftY /= maximum(fftY)
        if axis == true
            ax = Axis(fig[graphPosition[1], graphPosition[2]], xlabel = "Frequency (MHz)", ylabel = "Normalised Amplitude", title = title)
            plotOrigin(ax)
        end 
    end

    if axis != true
        ax = axis
    end

    scatterlines!(frequencies/1e6, fftY, color = color, markersize = dotSize, linewidth = lineThickness, label = label)

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

# --------------------------------------------------- #
#  P O W E R   S P E C T R A   C A L C U L A T I O N  #
# --------------------------------------------------- #

function powerSpectra(signal::Vector, fs::Number, returnFrequencies::Bool; 
                      paddingCount::Number=0)

    # Padding.
    if paddingCount != 0
        zerosVec = zeros(paddingCount) + im*zeros(paddingCount)
        append!(signal, zerosVec) 
    end

    # Calculate FFT.
    signalFFT = fft(signal)
    dcComplex = signalFFT[1]
    fftLength = length(signalFFT)

    # Odd FFT's.
    if fftLength % 2 == 1
        # FFT values.
        fftCenter = ceil(Int, fftLength/2)
        fftY = [ signalFFT[fftCenter+1 : end] ; signalFFT[1 : fftCenter] ]
        # Frequencies.
        frequencies = (-fftCenter+1:1:fftCenter-1) / fftCenter / 2 * fs

    # Even FFT's.
    else
        # FFT Values.
        fftHalve = trunc(Int, fftLength/2)
        fftY = [ signalFFT[fftHalve+2 : end] ; signalFFT[1 : fftHalve+1] ]
        # Frequencies
        frequencies = (-fftHalve+1:1:fftHalve) / fftHalve / 2 * fs
    end
    
    # Return types.
    if returnFrequencies == true
        return fftY, frequencies, dcComplex
    else
        return fftY, dcComplex 
    end

end

# ------- #
#  E O F  #
# ------- #
