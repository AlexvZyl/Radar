include("WaveformSpecs.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Utilities.jl")
include("Bezier.jl")

folder = "OptimalBezierResults/"
file = "Test.txt"
figure = Figure(resolution = (1920, 1080)) # 2D
deadzone = 50

# ------------- #
#  B E Z I E R  #
# ------------- #


# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 + pi)
# BezierSurface(BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, azimuth = pi/2 - pi/4 - pi/2, MLW = true, dB = 0)
# BezierContour(figure, BW, fs, resolution, nSamples, xRange = xRange, yRange = yRange, lobeWidthContourCount = 9, sideLobeContourCount = 13, dB = 0)
ho = BezierBayesionOptimised(figure, BW, fs, resolution, nSamples, sampleIterations, optimIterations, xRange = xRange, yRange = yRange, dB = 0, nPoints = points, plotHO = false, coordsCap = coordsCap, nParticles = particles)
hoFitness = ho.minimum[1]
bestParams = ho.minimum[2]

# Open file.
file = open(folder*file, "a")

# Header.
write(file, "\n---------------------------------------------------\n")

# Write optimiser parameters.
write(file, "\nSampleIterations: ")
write(file, string(sampleIterations))
write(file, "\nOptim Iterations: ")
write(file, string(optimIterations))
write(file, "\nResolution: ")
write(file, string(resolution))
write(file, "\nY Range: ")
write(file, string(yRange))
write(file, "\nX Range: ")
write(file, string(xRange))
write(file, "\nMax search coordinate: ")
write(file, string(maxSearchValue))
write(file, "\nParticles: ")
write(file, string(particles))

# Write the vertices to the file.
write(file, "\n\nvertices = [\n")
totalPoints = trunc(Int, length(bestParams))
vertices = Vector{Vertex2D}(undef, trunc(Int, totalPoints/2))
for i in 1:2:totalPoints
    write(file, "   ")
    write(file, string(Vertex2D(bestParams[i], bestParams[i+1])))
    vertices[trunc(Int, (i+1)/2)] = Vertex2D(bestParams[i], bestParams[i+1])
    write(file, ",\n")
end
write(file, "]\n")

# Log performance.
waveform = BezierSignalParametric(vertices, fs, nSamples, BW)
mf = plotMatchedFilter(figure, waveform, [1,1], fs, plot = false)
PSL = calculateSideLobeLevel(mf)
MLW = calculateMainLobeWidth(mf) / fs * BW 
write(file, "\nMLW (Nyquist samples): ")
write(file, string(MLW))
write(file, "\nPSL: ")
write(file, string(PSL))
write(file, "\nHO Fitness: ")
write(file, string(hoFitness))

# Footer.
write(file, "\n\n---------------------------------------------------")

# Close file.
close(file)
