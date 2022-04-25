# Script used to compare the results of the different waveforms.

# Phase Noise cancellation met DC offset.
# NLFM van Dr Steyn.

include("LFM.jl")
include("DeWitte_NLFM.jl")
include("Lesnik_NLFM.jl")
include("P4_PHASE_CODED.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Sigmoid.jl")
include("Utilities.jl")

# ----------- #
#  S E T U P  #
# ----------- #

figure = Figure(resolution = (1920, 1080))

# GENERAL WAVE DATA #

BW = 20e6
# BW = 120e6
fs = 50e6
# fs = 23e6
# fs = 110e6
# t_i = 50e-6
t_i = 3.3e-6
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

# SLL VS TBP #

fs = 120e6
tiRange = [60e-6, 60e-6]
bwRange = [0.01e6, 50e6]
parameterRange = [0.1, 1] 
# parameterSamples = 10
# tbSamples = 100
parameterSamples = 13
tbSamples = 3
lobeCount = 1
# BW = minimum(bwRange)
# t_i = minimum(tiRange)

# ------------------ #
#  L I N E A R  F M  #
# ------------------ #

# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = true, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange)
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrum", color = :orange)
# plotSignal(figure, LFM, [1,1], fs)

# ----------------- # 
#  D E   W I T T E  #
# ----------------- #

# Tuning parameters suggested by the paper.
# τ = 0.15e6   # Close in SLL
# 𝒳 = 1.7      # Far out SLL\
# TB = 270
# t_i = 200e-6
# ceiling = 14e6
# B = TB / t_i
# fs = 400e6
# nSamples = ceil(Int, fs * t_i)
# if nSamples % 2 == 0
#     nSamples += 1
#     t_i += inv(fs)
# end

# DeWitte, NULL = generateDeWitte(fs, B, ceiling, t_i, nSamples, 𝒳, τ, figure = figure, plot = false)
# plotSignal(figure, DeWitte, [1,1], fs)

# ax = plotPowerSpectra(figure, DeWitte, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# response, ax = plotMatchedFilter(figure, DeWitte, [1,1], fs, yRange = 120, title = "Matched Filter Response", label = "De Witte", color = :orange)

# ------------- #
#  L E S N I K  #
# ------------- #

# BW Mhz LFM
# plot = true
# LFM, NULL = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, color = :orange, label = "LFM", title="Frequencies")
# Lesnik, NULL  = generateLesnikNLFM(BW, fs, nSamples, t_i, figure = figure, label ="Leśnik", title ="Frequencies", plot = false)

# 2 MHz LFM
# wave, ax = generateLFM(2e6, fs, nSamples, 0, plot = true, fig = figure, color = :orange, label = "LFM", axis = false, title="Frequencies")
# Lesnik, ax  = generateLesnikNLFM(BW, fs, nSamples, t_i, plot = true, figure = figure, axis = ax, label ="Leśnik", title ="Frequencies")

# plotSignal(figure, Lesnik, [1,1], fs)

# Matched filters.
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 120, title = "Matched Filter Response", label = "LFM", color = :red)
# lesnikMF, ax = plotMatchedFilter(figure, Lesnik, [1,1], fs, title = "Leśnik NLFM Matched Filter Response", color = :blue, label = "Leśnik")
# println(calculateSideLobeLevel(lesnikMF, 3))

# Power spectrums.
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# ax = plotPowerSpectra(figure, Lesnik, [1,1], fs, dB = false, label = "Leśnik", title="Power Spectrums", color = :blue)#, xRange = 110 / 50 * 2)

# SLL vs TBP
# lesnikPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, plot = true, figure = figure)

# --------------------------- #
#  P 4   P H A S E   C O D E  #
# --------------------------- #

# p4Phase, ax = generateP4Code(fs, BW, nSamples, plot = false, figure = figure)
# plotMatchedFilter(figure, p4Phase, [1,1], fs, yRange = Inf, title = "P4 Phase Code Matched Filter Response", color = :blue, label = "")
# plotPowerSpectra(figure, p4Phase, [1,1], fs, dB = false, label = "", title="P4 Phase Power Spectrum", color = :blue)

# --------------- #
#  S I G M O I D  #
# --------------- #

# plotSigmoid()
# sigmoidWave, MULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = 1, color = :blue, label = "Logit" )
# plotPowerSpectra(figure, sigmoidWave, [1,1], fs, dB = false, label = "Logit", axis = ax)
# plotSignal(figure, sigmoidWave, [1,3], fs)
# sigmoidmf, ax =  plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 80, title = "Sigmoid NLFM Matched Filter Response", color = :blue, label = "Logit")
# SLL = calculateSideLobeLevel(sigmoidmf, 3)
# println(SLL)

# Plot plance.
sigmoidPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, figure = figure)

# ----------- # 
#  S E T U P  #
# ----------- # 

# display(figure)
# axislegend(ax, valign = :bottom)
# axislegend(ax)
# save("TEST.pdf", figure)

# --------------- #
#  S I G M O I D  #
# --------------- #

# save("Sigmoid_General.pdf", figure)
save("Sigmoid_Plane.pdf", figure)
# save("Sigmoid_NLFM_LTB_FREQ.pdf", figure)
# save("Sigmoid_NLFM_LTB_MF.pdf", figure)
# save("Sigmoid_NLFM_LTB_POWERSPECTRUM.pdf", figure)
# save("Sigmoid_Plane.pdf", figure)

# ----------------------------- #
#  L F M   P R O C E S S I N G  #
# ----------------------------- #

# save("LFM_PROC_PowerSpectra.pdf", figure)
# save("LFM_PROC_PC.pdf", figure)
# save("LFM_PROC_FREQ.pdf", figure)

# ------- #
#  L F M  #
# ------- #

# save("LFM_PowerSpectra.pdf", figure)
# save("LFM_PC.pdf", figure)
# save("LFM_FREQ.pdf", figure)

# ------------- #
#  L E S N I K  #
# ------------- #

# save("Lesnik_FREQ.pdf", figure)>)
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

# ------- #
#  E O F  #
# ------- #