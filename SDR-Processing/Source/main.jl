# ---------------------------------------------------------------------------- #
#  Modules.                                                                    #
# ---------------------------------------------------------------------------- #

using DataFrames
using FFTW
using GLMakie
set_theme!(theme_dark())
update_theme!(
  Axis = (
    leftspinevisible = true,
    rightspinevisible = true,
    topspinevisible = true,
    bottomspinevisible = true,
    bottomspinecolor = :gray90,
    topspinecolor = :gray90,
    leftspinecolor = :gray90,
    rightspinecolor = :gray90
    )
  )

# ---------------------------------------------------------------------------- #
#  Includes.                                                                   #
# ---------------------------------------------------------------------------- #

# Incudes.
include("BinaryProcessor.jl")

# ---------------------------------------------------------------------------- #
#  Binary loading.                                                             #
# ---------------------------------------------------------------------------- #

# File.
filepath = "SDR-Processing\\Data\\Testing\\B210_SAMPLES_Testing_11.bin"
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

# ---------------------------------------------------------------------------- #
#  Plotting.                                                                   #
# ---------------------------------------------------------------------------- #

plotSamplesRatio = 0.15
IchannelScaled = Ichannel[1:1:trunc(Int, length(Ichannel)*plotSamplesRatio)]
QchannelScaled = Qchannel[1:1:trunc(Int, length(Qchannel)*plotSamplesRatio)]
# Graph parameters.
textSize = 23
lineThickness = 4
dashThickness = 2.5
dotSize = 5
originThickness = 2
# Origin.
# Plot the data.
f = Figure()
# 2D Plotting the blocks.
# ax = Axis(f[1, 1], xlabel = "Sample", ylabel = "Amplitude", title = "TX\\RX Direct Connected",
#           titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
# vlines!(ax, 0, color = :white, linewidth=originThickness)
# hlines!(ax, 0, color = :white, linewidth=originThickness)
# plotIScat = scatter!(IchannelScaled, color = :blue, markersize=dotSize)
# plotILine = lines!(IchannelScaled, color = :blue, linewidth=lineThickness)
# plotQScat = scatter!(QchannelScaled, color = :orange, markersize=dotSize)
# plotQLine = lines!(QchannelScaled, color = :orange, linewidth=lineThickness)
# legend = Legend(
#     f[1,2],
#     [plotIScat, plotQScat],
#     ["I Channel", "Q Channel"],
#     labelsize = textSize
# )

# Draw the FFT.
FFT = abs.(fft(IchannelScaled + QchannelScaled*im))
logFFT = 20* log10.(FFT/maximum(FFT))
Axis(f[1, 1], xlabel = "k", ylabel = "Magnitude (dB)", title = "FFT",
     titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
fftSamples = collect(0:1:length(FFT)-1)./(length(FFT)-1)
lines!(fftSamples, logFFT, color = :blue, lineThickness=5)
display(f)
# # save("figure.pdf", f, pt_per_unit = 1)

# ---------------------------------------------------------------------------- #
#  EOF.                                                                        #
# ---------------------------------------------------------------------------- #
