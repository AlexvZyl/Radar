# Modules.
using DataFrames
using FFTW

include("Utilities.jl")
include("NLFM.jl")

# File.
filepath = "SDR-Processing\\Data\\Testing\\B210_SAMPLES_Testing_013.bin"
# Buffer size.
fileSizeBytes = filesize(filepath)
fileSizeFloats = floor(Int, fileSizeBytes / 4);
fileSizeSamples = fileSizeFloats / 2
# Read the raw data.
rawData = Array{Float32}(undef, fileSizeFloats)
read!(filepath, rawData)

# Load channel data.
Ichannel = rawData[1:2:fileSizeFloats]
Qchannel = rawData[2:2:fileSizeFloats]
rxSignal = Ichannel + im*Qchannel

# Plot the data.
fig = Figure()
plotSignal(fig, rxSignal, [1,1], 12e6, title="Signal", sampleRatio = 0.15)
display(fig)

# Draw the FFT.
# FFT = abs.(fft(Ichannel + Qchannel*im))
# Axis(f[1, 3], xlabel = "k", ylabel = "Magnitude", title = "FFT")
# scatterlines!(FFT, color = :blue)
# display(f)

# ------------------------------- #
#  P O S T   P R O C E S S I N G  #
# ------------------------------- #

# fs = 12e6
# BW = fs / 2.1
# tᵢ =  / fs
# # Signal.
# signal(t) = exp(im * 2π * Φ(t, tᵢ) * BW)
# # Time steps, given the smaples.
# t = range(0, tᵢ, step = inv(fs))
#
# txSignal = Array{Complex{Float32}}(undef, HDChirpNSamples)
#
# # Plot the signal.
# fig = Figure()
# plotSignal(signal, [1,1], fs)
# display(fig)
