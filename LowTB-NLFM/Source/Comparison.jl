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

# Low TBP (66)
BW = 20e6
t_i = 3.3e-6
fs = BW * 2.5

# High TBP (1000)
# t_i = 25e-6
# BW = 60e6
# fs = BW * 2.5

# Copmpared to paper.
# BW = 2e6
# fs = BW * 2.5
# t_i = 75e-6

nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

# ------------------ #
#  L I N E A R  F M  #
# ------------------ #

# LFM, ax = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange)
# println(calculateSideLobeLevel(response))
# println(calculateMainLobeWidth(response) / fs * BW )

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

# Lesnik.
# response, ax = plotMatchedFilter(figure, Lesnik, [1,1], fs, yRange = 120, title = "Matched Filter Response", label = "LFM", color = :red, plot = true)
# println(calculateSideLobeLevel(response))
# println(calculateMainLobeWidth(response) / fs * BW )

# lesnikMF, ax = plotMatchedFilter(figure, Lesnik, [1,1], fs, title = "Matched Filter Response", color = :blue, label = "Leśnik", axis = ax)

# Power spectrums.
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrums", color = :orange)
# ax = plotPowerSpectra(figure, Lesnik, [1,1], fs, dB = false, label = "Leśnik", title="Power Spectrums", color = :blue)#, xRange = 110 / 50 * 2)

# SLL vs TBP
# lesnikPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, plot = true, figure = figure)

# ------------- #
#  B E Z I E R  #
# ------------- #

# Used in paper.
# sampleIterations = 8
# optimIterations = 750
# resolution = 1000
# yRange = [-2,2]
# xRange = [-2,2]

# sampleIterations = 14
# optimIterations = 1000
resolution = 10
yRange = [-2,2]
xRange = [-2,2]
# maxSearchValue = 20
# particles = 100
# points = 4
# Setup coords cap.
# coordsCap = [ [], [] ]
# for i in 1:points*2
    # append!(coordsCap[1], -maxSearchValue)
    # append!(coordsCap[2],  maxSearchValue)
# end

# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 + pi)
# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 - pi/2, MLW = true, dB = 0)
# BezierContour(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeWidthContourCount = 9, sideLobeContourCount = 13, dB = 0)
BezierParetoFront(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, nPoints = 1)
# ho = BezierBayesionOptimised(figure, BW, fs, resolution, nSamples, sampleIterations, optimIterations, xRange = xRange, yRange = yRange, dB = 0, nPoints = points, plotHO = false, coordsCap = coordsCap, nParticles = particles)
# hoFitness = ho.minimum[1]
# bestParams = ho.minimum[2]

# Open file.
# file = open("LowTB-NLFM/Source/BezierOptimiserResults.txt", "a")

# Header.
# write(file, "\n---------------------------------------------------\n")

# Write optimiser parameters.
# write(file, "\nSampleIterations: ")
# write(file, string(sampleIterations))
# write(file, "\nOptim Iterations: ")
# write(file, string(optimIterations))
# write(file, "\nResolution: ")
# write(file, string(resolution))
# write(file, "\nY Range: ")
# write(file, string(yRange))
# write(file, "\nX Range: ")
# write(file, string(xRange))
# write(file, "\nMax search coordinate: ")
# write(file, string(maxSearchValue))
# write(file, "\nParticles: ")
# write(file, string(particles))

# Write the vertices to the file.
# write(file, "\n\nvertices = [\n")
# totalPoints = trunc(Int, length(bestParams))
# vertices = Vector{Vertex2D}(undef, trunc(Int, totalPoints/2))
# for i in 1:2:totalPoints
    # write(file, "   ")
    # write(file, string(Vertex2D(bestParams[i], bestParams[i+1])))
    # vertices[trunc(Int, (i+1)/2)] = Vertex2D(bestParams[i], bestParams[i+1])
    # write(file, ",\n")
# end
# write(file, "]\n")

# Log performance.
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf = plotMatchedFilter(figure, waveform, [1,1], fs, plot = false)
# PSL = calculateSideLobeLevel(mf)
# MLW = calculateMainLobeWidth(mf) / fs * BW 
# write(file, "\nMLW (Nyquist samples): ")
# write(file, string(MLW))
# write(file, "\nPSL: ")
# write(file, string(PSL))
# write(file, "\nHO Fitness: ")
# write(file, string(hoFitness))

# Footer.
# write(file, "\n\n---------------------------------------------------")

# Close file.
# close(file)

# --------
# Logit:
# --------
# SLL = -57.52
# MLW = 19.2
# --------
# Lesnik:
# --------
# SLL = -67.53
# MLW = 184
# --------

# freq = BezierFreqienciesParametric(params, nSamples, BW = BW)
# ax = Axis(figure[1,1])
# duration = nSamples/fs
# time = 0:duration/(nSamples-1):duration
# scatterlines!(time*1e6, freq/1e6)
# plotSignal(figure, waveform, [1,1], fs)
# ax = plotPowerSpectra(figure, waveform, [1,1], fs, dB = false)
# LFM, NULL = generateLFM(BW, fs, nSamples, 0, plot = false, fig = figure, label = "LFM", title = "Frequencies", color = :orange)
# response, ax = plotMatchedFilter(figure, LFM, [1,1], fs, yRange = 80, title = "Matched Filter Response", label = "LFM", color = :orange, axis = ax)
# ax = plotPowerSpectra(figure, LFM, [1,1], fs, dB = false, label = "LFM", title="Power Spectrum", color = :orange, axis = ax)

# Plot the different Bezier orders on top of each other.

# 4th.
# ax = Axis(figure[1,1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "Optimal Bézier Frequency Modulation")
# time = LinRange(0, nSamples/fs, nSamples) * 1e6
# vertices = [ Vertex2D(0.11210956f0, 1.0807872f0) ]
# # waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# # mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, label = "4th", title = "Optimal Bézier Pulse Compression")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "4th", color = :blue)

# 6th.
# vertices = [ Vertex2D(0.21581618f0, 0.44881594f0), Vertex2D(-0.47461903f0, 0.80749863f0) ]
# vertices = [ Vertex2D(-0.047584273f0, -0.42005837f0), Vertex2D(0.5834747f0, 0.8460692f0), Vertex2D(-1.2840363f0, 0.5929221f0) ]
# vertices = [ Vertex2D(0.13209973f0, -0.4626111f0), Vertex2D(-0.20302902f0, 1.5247223f0), Vertex2D(0.5904682f0, -0.77123034f0), Vertex2D(-0.84295666f0, 1.7347952f0) ]
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, color = :red, label = "6th")
# println("SLL: ", calculateSideLobeLevel(mf))
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "6th", color = :red)

# # 8th.
# vertices = [ Vertex2D(-0.047584273f0, -0.42005837f0), Vertex2D(0.5834747f0, 0.8460692f0), Vertex2D(-1.2840363f0, 0.5929221f0) ]
# # waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# # mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, axis = ax, color = :orange, label = "8th")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "8th", color = :orange)

# # 10th.
# vertices = [ Vertex2D(0.13209973f0, -0.4626111f0), Vertex2D(-0.20302902f0, 1.5247223f0), Vertex2D(0.5904682f0, -0.77123034f0), Vertex2D(-0.84295666f0, 1.7347952f0) ]
# # waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# # mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, axis = ax, color = :purple, label = "10th")
# freq = BezierFreqienciesParametric(vertices, nSamples, BW = BW) / 1e6
# scatterlines!(time, freq, markersize = dotSize, linewidth = lineThickness, label = "10th", color = :purple)

# # axislegend(ax)
# axislegend(ax, valign = :bottom)
# # ylims!(-80, 0)
# save("Article_LowTBP_CompareBezierOrders_Frequencies.pdf", figure)
# # save("Article_LowTBP_CompareBezierOrders.pdf", figure)

# High TBP (1000)
# 10th.
# time = LinRange(0, nSamples/fs, nSamples) * 1e6
# # 4-element Vector{Vertex2D}:
# vertices = [
#     Vertex2D(-0.79325163f0, -2.000197f0),
#     Vertex2D(1.4835511f0, 2.1629074f0),
#     Vertex2D(-1.1491517f0, -1.5636559f0),
#     Vertex2D(-0.50263745f0, 1.9820801f0)
# ]
# waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
# mf, ax = plotMatchedFilter(figure, waveform, [1,1], fs, label = "4th", title = "Optimal Bézier Pulse Compression", color = :orange, axis = ax)

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
# sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = 3.232, color = :blue, label = "Logit" )
# sigmoidmf, ax =  plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 80, title = "", color = :red, label = "Logit")#, axis = ax)
# println(calculateSideLobeLevel(sigmoidmf))
# println(calculateMainLobeWidth(sigmoidmf) / fs * BW)

# plotPowerSpectra(figure, sigmoidWave, [1,1], fs, dB = false, label = "Logit")#, axis = ax)
# plotSignal(figure, sigmoidWave, [1,1], fs)
# SLL = calculateSideLobeLevel(sigmoidmf, 3)
# println("SLL: ", SLL, " dB")

# param = OptimisedSigmoidSLL(BW, fs, nSamples)
# sigmoidWave, NULL = generateSigmoidWaveform(fs, BW, nSamples, plot = false, figure = figure, scalingParameter = param, color = :blue, label = "Logit" )
# plotMatchedFilter(figure, sigmoidWave, [1,1], fs, yRange = 80, title = "", color = :blue, label = "Logit", axis = ax)

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
# println(calculateSideLobeLevel(hyperMf))
# println(calculateMainLobeWidth(hyperMf) / fs * BW )
# OptimisedHyperbolicSLL(BW, fs ,nSamples)

# Plot the plane.
# plotHyperbolic(10)
# HyperbolicPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount, figure = figure)

# ----------- # 
#  S E T U P  #
# ----------- # 

# display(figure)
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
save("Article_LowTBP_4thOrder_PerformanceRange.pdf", figure)

# ------- #
#  E O F  #
# ------- #