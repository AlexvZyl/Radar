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

# ----------- # 
#  S E T U P  #
# ----------- # 

# display(figure)
# axislegend(ax, valign = :bottom)
# axislegend(ax)exe
# save("TEST.pdf", figure)
# save("Compare_All_Waveforms.pdf", figure)

 save("Article_LowTBP_Contour_0-0.pdf", figure)

# ------- #
#  E O F  #
# ------- #
