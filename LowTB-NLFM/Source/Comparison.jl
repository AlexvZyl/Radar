# Script used to compare the results of the different waveforms.

include("LFM.jl")
include("DeWitte_NLFM.jl")
include("Lesnik_NLFM.jl")
include("vanZyl_NLFM.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")

# ----------- #
#  S E T U P  #
# ----------- #

# Waveform parameters.
BW = 50e6
# BW = 2e6
fs = 150e6
t_i = 50e-6
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
    t_i += inv(fs)
end

# Makie setup.
figure = Figure(resolution = (1920, 1080))

# ------------------ #
#  L I N E A R  F M  #
# ------------------ #

# LFM = generateLFM(BW, fs, nSamples, 0, plot = true, fig = figure)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "LFM Matched Filter Response")
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="LFM Power Spectrum")
# plotSignal(figure, LFM, [1,1], fs)

# ----------------- # 
#  D E   W I T T E  #
# ----------------- #

Lesnik  = generateLesnikNLFM(BW, fs, nSamples, t_i, plot = true, figure = figure)

# ------------- #
#  L E S N I K  #
# ------------- #

# LesnikWaveform = generateLesnikNLFM(BW, fs, nSamples, t_i, true)
# Plotting.
# plotSignal(figure, LesnikWaveform, [1,1], fs)
# plotMatchedFilter(figure, LesnikWaveform, [1,1], fs, color = :orange,  label="Lesnik NLFM", axis = ax)
# plotPowerSpectra(figure, LesnikWaveform, [1,1], fs, dB = false, axis = ax, color = :orange, label = "Lesnik NLFM")

# --------------- #
#  V A N   Z Y L  #
# --------------- #



# ----------- # 
#  S E T U P  #
# ----------- # 

# axislegend(ax, linewidth = 10)
# save("LFM_PowerSpectra.pdf", figure)
# save("LFM_PC.pdf", figure)
# save("LFM_FREQ.pdf", figure)
save("Lesnik_FREQ.pdf", figure)
# display(figure)

# ------- #
#  E O F  #
# ------- #
