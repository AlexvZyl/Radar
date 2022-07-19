include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")

# freq = BezierFreqienciesParametric(params, nSamples, BW = BW)
# ax = Axis(figure[1,1])
# duration = nSamples/fs
# time = 0:duration/(nSamples-1):duration
# scatterlines!(time*1e6, freq/1e6)
# plotSignal(figure, waveform, [1,1], fs)
# ax = plotPowerSpectra(figure, waveform, [1,1], fs, dB = false)
# LFM, NULL = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange, axis = ax)
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrum", color = :orange, axis = ax)

# Plot the different Bezier orders on top of each other.
ax = Axis(figure[1,1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "Optimal Bézier Frequency Modulation")
time = LinRange(0, nSamples/fs, nSamples) * 1e6

# 4th.
vertices = [ Vertex2D(0.11210956f0, 1.0807872f0) ]
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, label = "4th", title = "Optimal Bézier Pulse Compression")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "4th", color = :blue)

# 6th.
vertices = [ Vertex2D(0.21581618f0, 0.44881594f0), Vertex2D(-0.47461903f0, 0.80749863f0) ]
# vertices = [ Vertex2D(-0.047584273f0, -0.42005837f0), Vertex2D(0.5834747f0, 0.8460692f0), Vertex2D(-1.2840363f0, 0.5929221f0) ]
# vertices = [ Vertex2D(0.13209973f0, -0.4626111f0), Vertex2D(-0.20302902f0, 1.5247223f0), Vertex2D(0.5904682f0, -0.77123034f0), Vertex2D(-0.84295666f0, 1.7347952f0) ]
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, color = :red, label = "6th")
# println("SLL: ", calculateSideLobeLevel(mf))
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "6th", color = :red)

# 8th.
vertices = [ Vertex2D(-0.047584273f0, -0.42005837f0), Vertex2D(0.5834747f0, 0.8460692f0), Vertex2D(-1.2840363f0, 0.5929221f0) ]
# # waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# # mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, axis = ax, color = :orange, label = "8th")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "8th", color = :orange)

# 10th.
vertices = [ Vertex2D(0.13209973f0, -0.4626111f0), Vertex2D(-0.20302902f0, 1.5247223f0), Vertex2D(0.5904682f0, -0.77123034f0), Vertex2D(-0.84295666f0, 1.7347952f0) ]
# # waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# # mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, axis = ax, color = :purple, label = "10th")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "10th", color = :purple)


# Saving the figure.
# axislegend(ax)
# axislegend(ax, valign = :bottom)
# # ylims!(-80, 0)
# save("Article_LowTBP_CompareBezierOrders_Frequencies.pdf", figure)
# # save("Article_LowTBP_CompareBezierOrders.pdf", figure)

# High TBP (1000)
# 10th.
# time = LinRange(0, nSamples/fs, nSamples) * 1e6
# # 4-element Vector{Vertex2D}:
# vertices = [
#     Vertex2D(-0.79325163f0, -2.000197f0),
#     Vertex2D(1.4835511f0, 2.1629074f0),
#     Vertex2D(-1.1491517f0, -1.5636559f0),
#     Vertex2D(-0.50263745f0, 1.9820801f0)
# ]
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, label = "4th", title = "Optimal Bézier Pulse Compression", color = :orange, axis = ax)
