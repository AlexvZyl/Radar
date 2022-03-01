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
fs = 50e6
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

# Tuning parameters suggested by the paper.
τ = 0.15e6    # Close in SLL
𝒳 = 1.7      # Far out SLL
TB = 270
t_i = 200e-6
ceiling = 14e6
B = TB / t_i
fs = 400e6
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
    t_i += inv(fs)
end

DeWitte, ax = generateDeWitte(fs, B, ceiling, t_i, nSamples, 𝒳, τ, figure = figure, plot = false)
# plotSignal(figure, DeWitte, [1,1], fs)

ax = plotPowerSpectra(figure, DeWitte, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# response, ax = plotMatchedFilter(figure, DeWitte, [1,1], fs, yRange = 120, title = "Matched Filter Response", label = "LFM", color = :orange)

# ------------- #
#  L E S N I K  #
# ------------- #

# 50 Mhz LFM
# plot = true
# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = plot, fig = figure, color = :orange, label = "LFM", axis = false, title="Frequencies")
# Lesnik, ax  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies")

# 2 MHz LFM
# wave, ax = generateLFM(2e6, fs, nSamples, 0, plot = true, fig = figure, color = :orange, label = "LFM", axis = false, title="Frequencies")
# Lesnik, ax  = generateLesnikNLFM(BW, fs, nSamples, t_i, plot = true, figure = figure, axis = ax, label ="Leśnik", title ="Frequencies")

# plotSignal(figure, Lesnik, [1,1], fs)

# Matched filters.
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange)
# plotMatchedFilter(figure, Lesnik, [1,1], fs, yRange = Inf, title = "Leśnik NLFM Matched Filter Response", color = :blue, label = "Leśnik")

# Power spectrums.
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# ax = plotPowerSpectra(figure, Lesnik, [1,1], fs, dB = false, label = "Leśnik", title="Power Spectrums", color = :blue)#, xRange = 110 / 50 * 2)

# --------------- #
#  V A N   Z Y L  #
# --------------- #



# ----------- # 
#  S E T U P  #
# ----------- # 

# axislegend(ax, valign = :bottom)
# axislegend(ax)
save("TEST.pdf", figure)

# ------- #
#  L F M  #
# ------- #

# save("LFM_PowerSpectra.pdf", figure)
# save("LFM_PC.pdf", figure)
# save("LFM_FREQ.pdf", figure)

# ------------- #
#  L E S N I K  #
# ------------- #

# save("Lesnik_FREQ.pdf", figure)
# save("Lesnik_PC.pdf", figure)
# save("Lesnik_PowerSpectrum.pdf", figure)
# save("Lesnik_FREQ_50MHz.pdf", figure)
# save("Lesnik_PC_50MHz.pdf", figure)
# save("Lesnik_PowerSpectrum_50MHz.pdf", figure)
# save("Lesnik_FREQ_LTB.pdf", figure)
# save("Lesnik_PC_LTB.pdf", figure)
# save("Lesnik_PowerSpectrum_LTB.pdf", figure)

# ----------------- #
#  D E   W I T T E  #
# ----------------- #

# save("DeWitte_FREQ.pdf", figure)
# save("DeWitte_PC.pdf", figure)
# save("DeWitte_PowerSpectrum.pdf", figure)
# display(figure)

# ------- #
#  E O F  #
# ------- #