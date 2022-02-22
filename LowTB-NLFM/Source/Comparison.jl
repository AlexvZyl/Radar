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
# BW = 20e6
fs = 110e6
# fs = 50e6
t_i = 50e-6
# t_i = 3.3e-6
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
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "LFM Matched Filter Response", label = "LFM")
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="LFM Power Spectrum")

# plotSignal(figure, LFM, [1,1], fs)

# ----------------- # 
#  D E   W I T T E  #
# ----------------- #



# ------------- #
#  L E S N I K  #
# ------------- #

# 50 Mhz LFM
plot = true
# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = plot, fig = figure, color = :orange, label = "LFM", axis = false, title="Frequencies")
# Lesnik, ax  = generateLesnikNLFM(BW, fs, nSamples, t_i, plot = plot, figure = figure, axis = ax, label ="Leśnik", title ="Frequencies")

# 2 MHz LFM
wave, ax = generateLFM(2e6, fs, nSamples, 0, plot = true, fig = figure, color = :orange, label = "LFM", axis = false, title="Frequencies")
Lesnik, ax  = generateLesnikNLFM(BW, fs, nSamples, t_i, plot = true, figure = figure, axis = ax, label ="Leśnik", title ="Frequencies")

# plotSignal(figure, Lesnik, [1,1], fs)

# Matched filters.
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange)
# plotMatchedFilter(figure, Lesnik, [1,1], fs, yRange = Inf, title = "Leśnik NLFM Matched Filter Response", color = :blue, axis = ax, label = "Leśnik")

# Power spectrums.
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# ax = plotPowerSpectra(figure, Lesnik, [1,1], fs, dB = false, label = "Leśnik", title="Power Spectrums", axis = ax, color = :blue)#, xRange = 110 / 50 * 2)


# --------------- #
#  V A N   Z Y L  #
# --------------- #



# ----------- # 
#  S E T U P  #

axislegend(ax, valign = :bottom)
# axislegend(ax)
# save("TEST.pdf", figure)
# save("LFM_PowerSpectra.pdf", figure)
# save("LFM_PC.pdf", figure)
# save("LFM_FREQ.pdf", figure)
save("Lesnik_FREQ.pdf", figure)
# save("Lesnik_PC.pdf", figure)
# save("Lesnik_PowerSpectrum.pdf", figure)
# save("Lesnik_FREQ_50MHz.pdf", figure)
# save("Lesnik_PC_50MHz.pdf", figure)
# save("Lesnik_PowerSpectrum_50MHz.pdf", figure)
# save("Lesnik_FREQ_LTB.pdf", figure)
# save("Lesnik_PC_LTB.pdf", figure)
# save("Lesnik_PowerSpectrum_LTB.pdf", figure)
# display(figure)

# ------- #
#  E O F  #
# ------- #
