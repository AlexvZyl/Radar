include("/home/alex/GitHub/Masters-Julia/LowTB-NLFM/Source/CppInterface.jl")

wave = generateOptimalBezier(Int32(7), Float64(20e6), Int32(22e6))

for i in 1:2:length(wave)
    println(wave[i], " + ", wave[i+1], "j")
end

precomputed = precomputedBezier7SamplesArray()
display(precomputed)

# include("/home/alex/GitHub/Masters-Julia/LowTB-NLFM/Source/Sigmoid.jl")
# include("/home/alex/GitHub/Masters-Julia/Utilities/Processing/PulseCompression.jl")

# signal = generateOptimalSigmoidForSDR(Int32(100), 20e6, Int32(22e6))
# figure = Figure()
# plotMatchedFilter(figure, signal, [1,1], 22e6, yRange = 60)
# plotSignal(figure, signal, [1,1], 22e6)
# display(figure)
