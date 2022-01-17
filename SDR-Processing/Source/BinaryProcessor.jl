# Modules.
using DataFrames
using FFTW
using Debugger

include("Utilities.jl")
include("NLFM.jl")

const C = 299792458
# We only want to load one second instead of loading the entire 14GB...
txTime = 5
fs = 23e6
totalPulses = 751634
samplesPerPulse = round(Int, fs / ( totalPulses / txTime ) )
totalSamplesSignal = samplesPerPulse * 5
totalSamplesFFT    = samplesPerPulse * 1000
secondsToLoad = 0.00005
samplesLoadRatio = secondsToLoad / txTime # Load one second.
# File.
filepath = "SDR-Processing/Data/Testing/B210_SAMPLES_Testing_083.bin"
fileSizeBytes = filesize(filepath)
# Buffer size.
fileSizeFloats = floor(Int, (fileSizeBytes / 4) * samplesLoadRatio);
if fileSizeFloats % 2 == 1
    fileSizeFloats += 1
    fileSizeFloats = trunc(Int, fileSizeFloats)
end
fileSizeSamples = fileSizeFloats / 2

samplesRatioSignal = totalSamplesSignal / fileSizeSamples
samplesRatioFFT = totalSamplesFFT / fileSizeSamples

# Read the raw data.
rawData = Array{Float32}(undef, fileSizeFloats)
read!(filepath, rawData)

# Load channel data.
Ichannel = rawData[1:2:fileSizeFloats]
Qchannel = rawData[2:2:fileSizeFloats]
rxSignal = Ichannel + im*Qchannel

# # Plot the data.
# fig = Figure()
# plotSignal(fig, rxSignal, [1,1], 23e6, title="Signal", sampleRatio = samplesRatioSignal)
# plotPowerSpectra(fig, rxSignal, [1,2], 23e6, sampleRatio = samplesRatioFFT)
# display(fig)

# =============================== #
#  P O S T   P R O C E S S I N G  #
# =============================== #

NLFM = true
LFM = ! NLFM

# --------- #
#  N L F M  #
# --------- #

if NLFM
    # Parameters.
    fs = 23e6
    BW = fs / 2.1
    deadZone = 495.309
    # Calculate the amount of samples.
    waveSamples = round(Int, (deadZone * 2 / C) * fs )
	# Check rounding.
    if (waveSamples % 2 == 0)
		# Check if rounded down.
		if ( (waveSamples / fs) * c / 2 < deadZone)
			waveSamples+=1
		# Rounded up.
		else
			waveSamples-=1
		end
	end
    txSignal = Array{Complex{Float32}}(undef, waveSamples)
    # Signal and time.
    tᵢ = waveSamples / fs
    signal(t) = exp(im * 2π * Φ(t, tᵢ) * BW)
    t = range(0, tᵢ, step = inv(fs))

    # Generate waveform.
    for n in 0:1:waveSamples-1
    	txSignal[n+1] = signal(t[n+1])
    end

    # Plot the signal.
    fig = Figure()
    plotSignal(fig, txSignal, [1,1], fs)
    plotMatchedFilter(fig, rxSignal, [1,2], fs, secondSignal = txSignal)
    display(fig)
end

# --------- #
#   L F M   #
# --------- #

if LFM

end

# ------- #
#  E O F  #
# ------- #
