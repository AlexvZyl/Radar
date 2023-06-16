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

# ----------------- #
#  P L O T T I N G  #
# ----------------- #

# fig = Figure()
#
# # PLot freq.
# ax = Axis(  fig[1,1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "LFM Instantaneous Frequency",
#             titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# time = collect(-(nSamples-1)/2:1:(nSamples-1)/2) ./ fs
# lines!(time * 1e6, freqVector / 1e6, color = :blue, linewidth = lineThickness)
# hlines!(ax, (BW/1e6)/2, color = :white, linewidth=originThickness, label = "Bandwidth")
# hlines!(ax, -(BW/1e6)/2, color = :white, linewidth=originThickness)
# axislegend(ax)
#
# # PLot wave.
# plotSignal(fig, wave, [1,2], fs)
# plotPowerSpectra(fig, wave, [1,3], fs, scatterPlot = true)
# plotMatchedFilter(fig, wave, [2,1], fs)
#
# # Display the Makie plot.
# display(fig)

# ------- #
#  E O F  #
# ------- #
