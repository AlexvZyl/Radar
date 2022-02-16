# The standard waveform used in radar transmission.
# A simple linear chirp that spans the bandwidth of
# the signal.

using CairoMakie

# ----------------- #
#  W A V E F O R M  #
# ----------------- #

function generateLFM(BW::Number, fs::Number, nSamples::Number, dcFreqShift::Number; plot::Bool = false, fig::Figure)

    if nSamples == 1
        return [1+0*im]
    end

    # Calculate LFM parameter.
    freqGradient = BW / (nSamples-1)

    # Data vectors.
    freqVector = Array{Float64}(undef, nSamples)
    wave = Array{Complex{Float64}}(undef, nSamples)

    # Create freq vector.
    for n in 0:1:nSamples-1
        freqVector[n+1] = ( (freqGradient * n) - (BW/2) )
    end

    # Create the waveform.
    offset = (nSamples-1) / 2
    for s in 0:1:(nSamples-1)
        n = s - offset
        fw = freqVector[s+1] / fs
        wave[s+1] = exp(pi * im * fw * n)
    end

    # Plot the frequencies.
    if plot
        ax = Axis(fig[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "Linear Frequency Modulation")
        plotOrigin(ax)        
        timeVec = (-offset:1:offset) / fs 
        lines!(timeVec * 1e6, freqVector / 1e6, linewidth = lineThickness, color = :blue)
    end

    return wave

end

# ------- #
#  E O F  #
# ------- #
