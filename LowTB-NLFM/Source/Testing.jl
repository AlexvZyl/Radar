include("/home/alex/GitHub/Masters-Julia/LowTB-NLFM/Source/Bezier.jl")
include("/home/alex/GitHub/Masters-Julia/LowTB-NLFM/Source/Sigmoid.jl")
include("/home/alex/GitHub/Masters-Julia/Utilities/Processing/PulseCompression.jl")

I = generateOptimalBezier(Int32(73), Float64(20e6), Int32(22e6))
println(I)

# signal = generateOptimalSigmoidForSDR(Int32(100), 20e6, Int32(22e6))

# figure = Figure()
# plotMatchedFilter(figure, signal, [1,1], 22e6, yRange = 60)
# plotSignal(figure, signal, [1,1], 22e6)
# display(figure)
