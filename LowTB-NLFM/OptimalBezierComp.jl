include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")
include("LFM.jl")
include("Lesnik_NLFM.jl")
include("Sigmoid.jl")
include("Hyperbolic.jl")
include("OptimalBezierResults.jl")

figure = Figure(resolution = (1920, 1080)) # 2D

# Generate all of the waveforms.
LFM, NULL = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
bezier4th = BezierSignalParametric(bezier4th, fs, nSamples, BW)
bezier6th = BezierSignalParametric(bezier6th, fs, nSamples, BW)
bezier8th = BezierSignalParametric(bezier8th, fs, nSamples, BW)
bezier10th = BezierSignalParametric(bezier10th, fs, nSamples, BW)

# Plot the macthed filters.
NULL, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "LFM",  color = :grey)
NULL, ax = plotMatchedFilter(figure, bezier4th, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "4th",  color = :blue, axis = ax)
NULL, ax = plotMatchedFilter(figure, bezier6th, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "6th",  color = :red , axis = ax)
NULL, ax = plotMatchedFilter(figure, bezier8th, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "8th",  color = :orange , axis = ax)
NULL, ax = plotMatchedFilter(figure, bezier10th, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "10th",  color = :purple, axis = ax)

# Saving the matched filter.
axislegend(ax)
save("Article_LowTBP_CompareBezierOrders.pdf", figure)

# Saving the modulation?...
# axislegend(ax, valign = :bottom)
# ylims!(-80, 0)
# save("Article_LowTBP_CompareBezierOrders_Frequencies.pdf", figure)

# Cant remember what this is for...
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
