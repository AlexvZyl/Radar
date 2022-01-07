# Modules.
using DataFrames
include("../../Utilities/MakieGL.jl")
using FFTW

# File.
filepath = "SDR-Processing\\Data\\Testing\\B210_SAMPLES_Testing_5.bin"
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

# Display data.
# Plot the data.
# figure = scene()
f = Figure()
# 2D Plotting the blocks.
ax = Axis(f[1, 1], xlabel = "Samples", ylabel = "Value", title = "Float32, I Q Blocks")
# xlims!(ax, 0, 8200)
# ylims!(ax, -18000, 18000)
plt1 = scatter!(Ichannel, color = :blue)
plt2 = scatter!(Qchannel, color = :orange)
legend = Legend(
    f[1,2],
    [plt1, plt2],
    ["I Channel", "Q Channel"]
)

# Draw the FFT.
FFT = abs.(fft(Ichannel + Qchannel*im))
Axis(f[1, 3], xlabel = "k", ylabel = "Magnitude", title = "FFT")
scatterlines!(FFT, color = :blue)
display(f)
# # save("figure.pdf", f, pt_per_unit = 1)
