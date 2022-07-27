include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")

figure = Figure(resolution = (1920, 1080)) # 2D

vertices = [
    Vertex2D(-0.75, -0.25)
]

nSamples = 1000
waveform = BezierFrequencies(vertices, nSamples)

ax = Axis(figure[1, 1], xlabel = "X", ylabel = "Y", title = "4th Order Bézier Example")
x = -1:2/(nSamples-1):1
lines!(x, waveform, color = :blue, linewidth = 5, label = "Curve")
verticesX = [-1, -0.75, 0, 0.75, 1]
verticesY = [-1, -0.25, 0, 0.25, 1]
lines!(verticesX, verticesY, color = :black, markersize = 20)
scatter!(verticesX, verticesY, color = :red, markersize = 20, label = "Vertices")

plotOrigin(ax, thickness = 4)
axislegend(ax, halign = :right, valign = :bottom)

save("Article_BasicBezierExample.pdf", figure)

kglkghkjgh