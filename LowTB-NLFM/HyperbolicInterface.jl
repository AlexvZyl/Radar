include("Hyperbolic.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")

file_name = "Hyperbolic_Plane.pdf"
figure = Figure(resolution = (1920, 1600))

# Wave data.
fs = 100e6
tiRange = [ 3.33e-6, 3.33e-6 ]
bwRange = [ 5e6, 30e6 ]
paramRange = [ 0.2, 40 ]
parameterSamples = 100
tbSamples = 100

# Generate wave.
HyperbolicPlane(fs, tiRange, bwRange, paramRange, parameterSamples, tbSamples, title = "Sinh PSL Performance Surface", figure = figure, plot = true)

# Save wave.
save(file_name, figure)
