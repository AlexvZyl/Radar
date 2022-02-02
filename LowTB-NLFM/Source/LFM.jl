# The standard waveform used in radar transmission.
# A simple linear chirp that spans the bandwidth of
# the signal.

# ----------------- #
#  W A V E F O R M  #
# ----------------- #

function generateLFM(BW::Number, fs::Number, nSamples::Number, dcFreqShift::Number)

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
    for n in 0:1:nSamples-1
        index = n - offset
        k = (index * freqVector[n+1]) / fs
        wave[n+1] = exp(pi * im * k)
    end

    return wave

end

# ------- #
#  E O F  #
# ------- #
