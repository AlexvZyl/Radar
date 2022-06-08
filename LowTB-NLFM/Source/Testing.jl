include("/home/alex/GitHub/Masters-Julia/LowTB-NLFM/Source/Bezier.jl")

I = generateOptimalBezier(Int32(73), Float64(20e6), Int32(22e6))
println(I)

