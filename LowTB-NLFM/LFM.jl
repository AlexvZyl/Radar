# The standard waveform used in radar transmission.
# A simple linear chirp that spans the bandwidth of
# the signal.

using CairoMakie

function LFMFreq(nSamples, BW)

    if nSamples == 1
        return [1+0*im]
    end

    # Calculate LFM parameter.
    freqGradient = BW / (nSamples-1)

    # Data vectors.
    freqVector = Array{Float64}(undef, nSamples)

    # Create freq vector.
    for n in 0:1:nSamples-1
        freqVector[n+1] = ( (freqGradient * n) - (BW/2) )
    end

    return freqVector
end

# ----------------- #
#  W A V E F O R M  #
# ----------------- #

function generateLFM(BW::Number, fs::Number, nSamples::Number, dcFreqShift::Number; plot::Bool = false, fig::Figure, color = :blue, label = "", axis = false,
                    title = "Linear Frequency Modulation")

    # Data vectors.
    freqVector = LFMFreq(nSamples, BW)
    wave = Array{Complex{Float64}}(undef, nSamples)

    # Create the waveform.
    offset = (nSamples-1) / 2
    for s in 0:1:(nSamples-1)
        n = s - offset
        fw = freqVector[s+1] / fs
        wave[s+1] = exp(pi * im * fw * n)
    end

    # Plot the frequencies.
    if plot

        if axis == false

            ax = Axis(fig[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            plotOrigin(ax)        
            timeVec = (0:1:nSamples-1) / fs 
            scatterlines!(timeVec * 1e6, freqVector / 1e6, linewidth = lineThickness, color = color, fxaa = true, markersize = dotSize, label = label)
            axis = ax
        
        else 
            
            timeVec = (0:1:nSamples-1) / fs 
            scatterlines!(timeVec * 1e6, freqVector / 1e6, linewidth = lineThickness, color = color, fxaa = true, markersize = dotSize, label = label)
            
        end

    end

    return wave, axis

end

# ------- #
#  E O F  #
# ------- #
