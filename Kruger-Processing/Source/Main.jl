# ============================================================ #
# Modules.                                                     #
# ============================================================ #

# Drawing engine.
using GLMakie
# Set Makie theme.
set_theme!(theme_dark())

# Data.
using DataFrames
using FloatingTableView
using MAT

# Processing.
using FFTW

# ============================================================ #
# Includes.                                                    #
# ============================================================ #

include("BinaryProcessor.jl")
include("SignalProcessor.jl")

# ============================================================ #
# Processing.                                                  #
# ============================================================ #

# Read a binary folder.
# data = readBinaryFolder("Environments\\RadarProcessing\\RadarData-Binary\\Rhino\\")

# Read a binary file.
# filename = "Capture_908.bin"
file = readBinaryFile("RadarProcessing\\RadarData-Binary\\Giraffe\\Capture_908.bin")

# Calculate the fft.
FFT = complexFFT(125/16 * 10^6, file.I[1], file.Q[1])

# ============================================================ #
# Drawing.                                                     #
# ============================================================ #

# Plot the data.
# figure = scene()
f = Figure()
# 2D Plotting the blocks.
ax = Axis(f[1, 1], xlabel = "Samples", ylabel = "Value", title = "Int16, I Q Blocks")
# xlims!(ax, 0, 8200)
# ylims!(ax, -18000, 18000)
plt1 = scatter!(file.I[10], color = :blue)
plt2 = scatter!(file.Q[10], color = :orange)
legend = Legend(
    f[1,2],
    [plt1, plt2],
    ["I Channel", "Q Channel"]
)

# Draw the FFT.
# Axis(f[1, 3], xlabel = "k", ylabel = "Magnitude", title = "FFT")
# scatterlines!(FFT, color = :blue)
display(f)
# # save("figure.pdf", f, pt_per_unit = 1)

# ============================================================ #
println("EOS.")                                                #
# ============================================================ #
