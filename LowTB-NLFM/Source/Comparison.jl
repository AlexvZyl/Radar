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
include("Bezier.jl")
include("Hyperbolic.jl")

# ----------- #
#  S E T U P  #
# ----------- #

figure = Figure(resolution = (1920, 1080)) # 2D
# figure = Figure()
# figure = Figure(resolution = (1920-600, 1080)) # 3D

# GENERAL WAVE DATA #

# High TBP.
# BW = 50e6
# fs = 110e6
# t_i = 50e-6

# Low TBP.
BW = 20e6
fs = BW * 2.5
# fs = 50e6
# fs = BW * 2
t_i = 3.3e-6

nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

# ------------------ #
#  L I N E A R  F M  #
# ------------------ #

# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
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

# lesnikMF, ax = plotMatchedFilter(figure, Lesnik, [1,1], fs, title = "Matched Filter Response", color = :blue, label = "Leśnik", axis = ax)

# Power spectrums.
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# ax = plotPowerSpectra(figure, Lesnik, [1,1], fs, dB = false, label = "Leśnik", title="Power Spectrums", color = :blue)#, xRange = 110 / 50 * 2)

# SLL vs TBP
# lesnikPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, plot = true, figure = figure)

# ------------- #
#  B E Z I E R  #
# ------------- #

resolution = 300
yRange = [0,2]
xRange = [-1,1]
BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeCount = 10, azimuth = pi/2 - pi/4 + pi)
# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeCount = 10, azimuth = pi/2 - pi/4 - pi/2, MLW = true, dB = 0)
# BezierContour(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeCount = 10, lobeWidthContourCount = 9, sideLobeContourCount = 13, dB = 0)
# BezierParetoFront(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeCount = 10, lobeWidthContourCount = 9, sideLobeContourCount = 13, dB = 0, nPoints = 1)

# Testing the effect of adding points.
# params = [ Vertex2D(-0.2, 2) ]
# # waveform = BezierSignalParametric(params, fs, nSamples, BW)
# freq = BezierFreqienciesParametric(params, nSamples, BW = BW)
# ax = Axis(figure[1,1])
# duration = nSamples/fs
# time = 0:duration/(nSamples-1):duration
# scatterlines!(time*1e6, freq/1e6)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs)
# plotSignal(figure, waveform, [1,1], fs)
# ax = plotPowerSpectra(figure, waveform, [1,1], fs, dB = false)
# LFM, NULL = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange, axis = ax)
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrum", color = :orange, axis = ax)

# --------------- #
#  S I G M O I D  #
# --------------- #

# SLL VS TBP #
# fs = 120e6
# tiRange = [60e-6, 60e-6]
# bwRange = [0.01e6, 50e6]
# parameterRange = [0, 6] 
# parameterSamples = 50
# tbSamples = 50
# lobeCount = 3

# plotSigmoid(4.5)

# sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = 2.828, color = :blue, label = "Logit" )
# sigmoidmf, ax =  plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 80, title = "", color = :red, label = "Logit")#, axis = ax)
# println(calculateSideLobeLevel(sigmoidmf, 10))
# println(calculateMainLobeWidth(sigmoidmf))

# plotPowerSpectra(figure, sigmoidWave, [1,1], fs, dB = false, label = "Logit")#, axis = ax)
# plotSignal(figure, sigmoidWave, [1,1], fs)
# SLL = calculateSideLobeLevel(sigmoidmf, 3)
# println("SLL: ", SLL, " dB")

#OptimisedSigmoidSLL(BW, fs ,nSamples)

# Plot plance.
# sigmoidPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, figure = figure)

# --------------------- #
#  H Y P E R B O L I C  #
# --------------------- #

# SLL VS TBP #
# fs = 120e6
# tiRange = [60e-6, 60e-6]
# bwRange = [0.01e6, 50e6]
# parameterRange = [0, 15] 
# parameterSamples = 200
# tbSamples = 50
# lobeCount = 1000

# hypSignal, NULL = generateHyperbolicWaveform(fs, BW, nSamples, scalingParameter = 4.7979)
# hyperMf, ax =  plotMatchedFilter(figure, hypSignal, [1,1], fs, yRange = 80, title = "", color = :purple, label = "Sinh", axis = ax)

# OptimisedHyperbolicSLL(BW, fs ,nSamples)

# Plot the plane.
# plotHyperbolic(10)
# HyperbolicPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, figure = figure)

# ----------- # 
#  S E T U P  #
# ----------- # 

display(figure)
# axislegend(ax, valign = :bottom)
# axislegend(ax)exe
# save("TEST.pdf", figure)
# save("Compare_All_Waveforms.pdf", figure)

# --------------- #
#  S I G M O I D  #
# --------------- #

# save("Sigmoid_General.pdf", figure)
# save("Sigmoid_Plane.pdf", figure)
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

# ------------------------------- #
#  A R T I C L E   F I G U R E S  #
# ------------------------------- #

# save("Article_LowTBP_Comparisson_No_Bezier.pdf", figure)
# save("Article_LowTBP_SLL_SURFACE.pdf", figure)
# save("Article_LowTBP_MLW_SURFACE.pdf", figure)
# save("Article_LowTBP_Contour_0-0.pdf", figure)
# save("Article_LowTBP_Pareto_0-0.pdf", figure)

# ------- #
#  E O F  #
# ------- #