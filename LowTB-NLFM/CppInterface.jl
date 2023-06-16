# include("Bezier.jl")

function generateOptimalBezierCF32(nSamples::Int32, BW::Float64, fs::Int32)
    vertices = [ Vertex2D(-0.047584273f0, -0.42005837f0), Vertex2D(0.5834747f0, 0.8460692f0), Vertex2D(-1.2840363f0, 0.5929221f0) ]
    BezierSignalParametric(vertices, Real(fs), Int(nSamples), Real(BW))
end

function generateOptimalBezier(nSamples::Int32, BW::Float64, fs::Int32)
    complexWave = generateOptimalBezierCF32(nSamples, BW, fs)
    floatWave = Vector{Float64}(undef, nSamples*2)
    floatWave[1:2:end-1] =  Float64.(real.(complexWave))
    floatWave[2:2:end] =  Float64.(imag.(complexWave))
    return floatWave
end

function precomputedBezier7SamplesComplexF64()
    return ComplexF64[
        ComplexF64(1.0, 0.0),
        ComplexF64(0.4487713873386383, -0.8936465978622437),
        ComplexF64(0.05674717202782631, -0.9983885884284973),
        ComplexF64(-0.07998809963464737, -0.9967958331108093),
        ComplexF64(0.05674717202782631, -0.9983885884284973),
        ComplexF64(0.4489729404449463, -0.8935453295707703),
        ComplexF64(1.0, 0.0),
    ]
end

function precomputedBezier7SamplesArray()
    return [
        1.0, 0.0,
        0.4487713873386383, -0.8936465978622437,
        0.05674717202782631, -0.9983885884284973,
        -0.07998809963464737, -0.9967958331108093,
        0.05674717202782631, -0.9983885884284973,
        0.4489729404449463, -0.8935453295707703,
        1.0, 0.0,
    ]
end
