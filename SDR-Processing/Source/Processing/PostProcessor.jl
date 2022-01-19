include("../PlotUtilities.jl")

# ======================= #
#  B I N A R Y   D A T A  #
# ======================= #

include("BinaryProcessor.jl")

file = "../SDR-Interface/build/Data/Testing/B210_SAMPLES_Testing_106.bin"
secondsToLoad = 0.0005
samplesPerPulse = 153
rxSignal = loadDataFromBin(file, loadRatio = 0.0002)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #

# --------- #
#   L F M   #
# --------- #

include("../Waveforms/LFM.jl")


LFM = true

if LFM

	# Create the LFM signal.
	nSamples = 77
	fs = 23e6
	BW = fs / 2.1
	txSignal = createLFM(BW, fs, nSamples)

	# Plots.
    figure = Figure()
    plotMatchedFilter(figure, rxSignal, [1,2], fs, secondSignal = txSignal, yRange = 45, xRange = 50)
	# plotSignal(figure, txSignal, [1,1], fs)
    plotSignal(figure, rxSignal, [1,1], fs, sampleRatio = 0.2)
	plotIQCircle(figure, rxSignal, [1,1])
    display(figure)

end

# --------- #
#  N L F M  #
# --------- #

NLFM = ! LFM

if NLFM

	fs = 23e6
	bw = fs / 2.1
	nSamples = 77
	tᵢ = nSamples / fs
	# Transmission interval.
	# Time steps, given the smaples.
	timePositive = collect((0:1:nSamples-1)) / fs
	txSignal = Array{Complex{Float32}}(undef, nSamples)
	PHASE = Φ.(timePositive, tᵢ, bandwidth)
	txSignal = exp.(2 * pi * im * bw * PHASE)

	# Plot NLFM.
	figure = Figure()

    # Plot the signal.
	# plotSignal(figure, txSignal, [1,1], fs)
    plotSignal(figure, rxSignal, [1,1], fs, sampleRatio = 0.2)
    plotMatchedFilter(figure, rxSignal, [1,2], fs, secondSignal = txSignal, yRange = 45, xRange = 50)
	# plotPowerSpectra(figure, rxSignal, [1,1], fs)

	# I vs Q plots.
	# ax = Axis(  figure[1,2], xlabel = "I Channel", ylabel = "Q Channel", title = "I vs Q",
	#             titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
	# rxNormFactor = maximum(max.(maximum(real(rxSignal)), imag(rxSignal)))
	# txNormFactor = maximum(max.(maximum(real(txSignal)), imag(txSignal)))
	# scatter!(real(rxSignal)/rxNormFactor, imag(rxSignal)/rxNormFactor,
	# 		 color = :blue, markersize = dotSize, label="RX Signal")
	# scatter!(real(txSignal)/txNormFactor, imag(txSignal)/txNormFactor,
	# 		 color = :red, markersize = dotSize, label="TX Signal")
 	# axislegend(ax)
    display(figure)

end

# ======= #
#  E O F  #
# ======= #
