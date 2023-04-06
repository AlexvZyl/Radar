include("LFM.jl")
include("Lesnik_NLFM.jl")
include("Sigmoid.jl")
include("Hyperbolic.jl")

include("../../Utilities/Processing/ProcessingHeader.jl")
include("../../Utilities/MakieGL/MakieGL.jl")
include("Utilities.jl")

# Waveform specs.
fs = 23e6
BW = 20e6
t_i = 3.3e-6
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

# Plot the waveform modulation.
figure = Figure(resolution = (1920, 1080))
LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = true, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
Lesnik, NULL  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies", plot = true, axis = ax, color = :red)
sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = true, figure = figure, scalingParameter = 2.828, color = :blue, label = "Logit", axis = ax, durationScale = t_i * 1e6)
hypSignal, NULL = generateHyperbolicWaveform(fs, BW, nSamples, scalingParameter = 4.7979, plot = true, axis = ax, timeScale = t_i * 1e6, color = :purple, label="Sinh")
axislegend(ax, valign = :bottom)
save("Baseline_Waveforms_Modulations.pdf", figure)
