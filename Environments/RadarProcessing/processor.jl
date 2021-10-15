# Setup.
clearconsole();

# ============================================================ #
# Packages.                                                    #
# ============================================================ #

# Drawing engine.
using GLMakie
# Set Makie theme.
set_theme!(theme_dark())

using DataFrames
using FloatingTableView
using BinaryProcessing

# ============================================================ #
# Testing.
# ============================================================ #

data = readBinaryFile("Environments\\RadarProcessing\\RadarData-Binary\\Rhino\\Capture_1000.bin")

# Plot the data.
f = Figure()
ax = Axis(f[1, 1], xlabel = "I Channel", ylabel = "Value",
    title = "Pulse 0 For Rhino Bin")
scatter!(data.Q[1])
display(f)

# ============================================================ #
println("EOS.")
# ============================================================ #
