# ================= #
#  I N C L U D E S  #
# ================= #

include("../PlotUtilities.jl")
include("BinaryProcessor.jl")
include("../Waveforms/LFM.jl")
include("DopplerFFT.jl")
include("PulseCompression.jl")

# ===================== #
#  P A R A M E T E R S  #
# ===================== #

# Create the LFM signal.
nSamplesWave 	= trunc(Int32, 7)
nSamplesPulse 	= trunc(Int32, 38)
fs 				= trunc(Int32, 23e6)
fc 				= 900e6
BW 				= fs / 2.1
# Specify as 0 to load all of the data.
pulsesToLoad 	= 600000
PRF 			= 605263

# ======================= #
#  B I N A R Y   D A T A  #
# ======================= #

file 			= "../SDR-Interface/build/Data/Testing/B210_SAMPLES_Testing_126.bin"
rxSignal 		= loadDataFromBin(file, pulsesToLoad = pulsesToLoad, samplesPerPulse = nSamplesPulse)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #

# --------- #
#   L F M   #
# --------- #

LFM = true
# LFM = false

if LFM

	#  W A V E F O R M  #

	txSignal = createLFM(BW, fs, nSamplesWave)

	#  P R O C E S S I N G  #

	# Processing.
    PCsignal = pulseCompression(rxSignal, txSignal)
	# Plot the Doppler Spectogram.
    figure = Figure()
	plotDopplerFFT(figure, PCsignal, [1,1], [1,nSamplesPulse*10], fc, fs, nSamplesPulse, [0,100], 
				   xRange = Inf, yRange = 60, nWaveSamples=nSamplesWave)
    display(figure)

end

# --------- #
#  N L F M  #
# --------- #

# NLFM = ! LFM
#
# if NLFM
#
# 	fs = 23e6
# 	bw = fs / 2.1
# 	nSamples = 77
# 	tᵢ = nSamples / fs
# 	# Transmission interval.
# 	# Time steps, given the smaples.
# 	timePositive = collect((0:1:nSamples-1)) / fs
# 	txSignal = Array{Complex{Float32}}(undef, nSamples)
# 	PHASE = Φ.(timePositive, tᵢ, bandwidth)
# 	txSignal = exp.(2 * pi * im * bw * PHASE)
#
# 	# Plot NLFM.
# 	figure = Figure()
#
#     # Plot the signal.
# 	# plotSignal(figure, txSignal, [1,1], fs)
#     plotSignal(figure, rxSignal, [1,1], fs, sampleRatio = 0.2)
#     plotMatchedFilter(figure, rxSignal, [1,2], fs, secondSignal = txSignal, yRange = 45, xRange = 50)
# 	# plotPowerSpectra(figure, rxSignal, [1,1], fs)
#
# 	# I vs Q plots.
# 	# ax = Axis(  figure[1,2], xlabel = "I Channel", ylabel = "Q Channel", title = "I vs Q",
# 	#             titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# 	# rxNormFactor = maximum(max.(maximum(real(rxSignal)), imag(rxSignal)))
# 	# txNormFactor = maximum(max.(maximum(real(txSignal)), imag(txSignal)))
# 	# scatter!(real(rxSignal)/rxNormFactor, imag(rxSignal)/rxNormFactor,
# 	# 		 color = :blue, markersize = dotSize, label="RX Signal")
# 	# scatter!(real(txSignal)/txNormFactor, imag(txSignal)/txNormFactor,
# 	# 		 color = :red, markersize = dotSize, label="TX Signal")
#  	# axislegend(ax)
#     display(figure)
#
# end

# ======= #
#  E O F  #
# ======= #
