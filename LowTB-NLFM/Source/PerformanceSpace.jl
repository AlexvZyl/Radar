include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")

figure = Figure(resolution = (1920, 1080))

BezierParetoFront(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, nPoints = 1)

save("Article_LowTBP_4thOrder_PerformanceRange.pdf", figure)

