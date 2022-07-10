include("../../Utilities/MakieGL/PlotUtilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")

# Variables.
j = complex(0,1)
BW = 2       # Signal bandwidth.
τ = 3           # Signal duration.
fs = 50       # Sampling frequency.

# Generate signal.
f(t) = exp(2π*j*BW*t)
freq(t) = BW * (t / τ - 0.5)
time = 0:τ/fs:τ
signal = freq.(time)

# Plot signal.
fig = Figure(resolution = (1920, 1080)) # 2D
Axis(fig[1,1])
scatterlines!(time, signal)
save("TestingLFM.pdf", fig)
