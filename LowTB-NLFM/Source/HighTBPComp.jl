include("LFM.jl")
include("DeWitte_NLFM.jl")
include("Lesnik_NLFM.jl")
include("P4_PHASE_CODED.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Sigmoid.jl")
include("Utilities.jl")
include("Bezier.jl")
include("Hyperbolic.jl")

figure = Figure(resolution = (1920, 1080)) # 2D
# figure = Figure()
# figure = Figure(resolution = (1920-600, 1080)) # 3D

# Parameters.
t_i = 25e-6
BW = 60e6
fs = BW * 2.5
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

# Bezier 10th orde.
time = LinRange(0, nSamples/fs, nSamples) * 1e6
vertices = [
    Vertex2D(-0.79325163f0, -2.000197f0),
    Vertex2D(1.4835511f0, 2.1629074f0),
    Vertex2D(-1.1491517f0, -1.5636559f0),
    Vertex2D(-0.50263745f0, 1.9820801f0)
]
waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, label = "4th", title = "Optimal Bézier Pulse Compression", color = :orange, yRange = 80)

# Sigmoid.
param = OptimisedSigmoidSLL(BW, fs, nSamples)
sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = param, color = :blue, label = "Logit" )
mf, ax = plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 80, title = "", color = :blue, label = "Logit", axis = ax)

# Lesnik.
Lesnik, NULL  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies", plot = false)
response, NULL = plotMatchedFilter(figure, Lesnik, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :red, plot = true, axis = ax)
println(calculateSideLobeLevel(response))
println(calculateMainLobeWidth(response) / fs * BW )

save("TEST.pdf", figure)