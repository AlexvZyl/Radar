# Script used to compare the results of the different waveforms.

# Phase Noise cancellation met DC offset.
# NLFM van Dr Steyn.

include("WaveformSpecs.jl")
include("LFM.jl")
include("DeWitte_NLFM.jl")
include("Lesnik_NLFM.jl")
include("P4_PHASE_CODED.jl")
include("Sigmoid.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Utilities.jl")
include("Hyperbolic.jl")
include("Bezier.jl")

# ----------- #
#  S E T U P  #
# ----------- #

figure = Figure(resolution = (1920, 1080)) # 2D
# figure = Figure()
# figure = Figure(resolution = (1920-600, 1080)) # 3D

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

# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 + pi)
# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 - pi/2, MLW = true, dB = 0)
# BezierContour(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeWidthContourCount = 9, sideLobeContourCount = 13, dB = 0)
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

# --------------- #
#  S I G M O I D  #
# --------------- #

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

# ------- #
#  E O F  #
# ------- #
