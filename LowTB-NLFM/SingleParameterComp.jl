include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")
include("LFM.jl")
include("Lesnik_NLFM.jl")
include("Sigmoid.jl")
include("Hyperbolic.jl")

# figure = Figure(resolution = (1920, 1080)) # 2D

# Generate the waveforms.
# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# Lesnik, NULL  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies", plot = false)
# sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = 2.828, color = :blue, label = "Logit" )
# hypSignal, NULL = generateHyperbolicWaveform(fs, BW, nSamples, scalingParameter = 4.7979)

# Generate matched filters.
# NULL, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "LFM",  color = :orange)
# NULL, ax = plotMatchedFilter(figure, Lesnik, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "Leśnik",  color = :blue, axis = ax)
# NULL, ax = plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "Logit",  color = :red, axis = ax)
# NULL, ax = plotMatchedFilter(figure, hypSignal, [1,1], fs, yRange = 60, xRange = t_i * 1e6 * 2, plot = true, label = "Sinh",  color = :purple, axis = ax)

# axislegend(ax)
# save("Article_LowTBP_Comparisson_No_Bezier.pdf", figure)

# Plot the waveform modulation.
figure = Figure(resolution = (1920, 1080)) # 2D
LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = true, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
Lesnik, NULL  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies", plot = true, axis = ax, color = :red)
sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = true, figure = figure, scalingParameter = 2.828, color = :blue, label = "Logit", axis = ax, durationScale = t_i * 1e6)
hypSignal, NULL = generateHyperbolicWaveform(fs, BW, nSamples, scalingParameter = 4.7979, plot = true, axis = ax, timeScale = t_i * 1e6, color = :purple)
axislegend(ax, valign = :bottom)
save("Article_LowTBP_SingleParameterFreq.pdf", figure)

generateDette(sasdsdf)
