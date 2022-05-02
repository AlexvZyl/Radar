using Interpolations
include("Vertex.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")

#  The Polynomial from of the Bezier curve (see BezierPolynomial.png):

#  t: 0 ⋜ t ⋜ 1 (Can be viewed as the normalised sample).
#  n: The order (number of points - 1) of the curve.
#  Cⱼ: The Bezier polynomial.
#  Pᵢ: The point, in the form (x, y).

# Calculate the Bezier polynomial for the given order.
# n: The order of the polynomial (Total points).
# j: The index in the order (vertex) of the curve.
# P: The point it is currently calculated for.
function Cⱼ(j::Real, vertices::Vector{Vertex2D})

    # Calculate the order of the Curve.
    n = length(vertices) - 1

    # Calculate the product.
    product = factorial(n) / factorial(n - j)

    # Calculate the sum.
    sum = Vertex2D(0, 0)
    for i in 0:1:j
        num = (-1)^(i+j) * vertices[i+1]
        den = factorial(i) * factorial(j-i)
        sum += (num / den)
    end

    return sum * product

end

# Create a single vertex for the Bezier, using the polynomial form.
# t: The Bezier sample.
# vertices: The points making up the Bezier curve.
function Bₚ(t::Real, vertices::Vector{Vertex2D})

    # Calculate the order of the Curve.
    n = length(vertices) - 1

    # Calculate the bezier point.
    sum = Vertex2D(0, 0)
    for j in 0:1:n
        sum += (t^j) * Cⱼ(j, vertices)
    end

    # Return the point.
    return sum

end

# Create a single vertex for the Bezier curve, using the explicit form.
# t: The Bezier sample.
# vertices: The points making up the Bezier curve.
function Bₑ(t::Real, vertices::Vector{Vertex2D})

    # Calculate the order of the Curve.
    n = length(vertices) - 1

    # Calculate the vertex.
    vertex = Vertex2D(0, 0)
    for i in 0:1:n
        vertex += binomial(n,i) * (1-t)^(n-i) * (t^i) * vertices[i+1]
    end
    
    return vertex

end

# Construct a Bezier curve.
# vertices: The points the Bezier curve is made of.
# nSamples:  The amount of samples used to construct the curve (higher = increased resolution).
function Bezier(vertices::Vector{Vertex2D}, nSamples::Real)

    # Setup the vectors.
    tVector = 0:1/(nSamples-1):1
    xVector = Vector{Float32}(undef, nSamples)
    yVector = Vector{Float32}(undef, nSamples)

    # Loop over the samples. 
    index = 1
    for t in tVector
        # result = Bₚ(t, vertices)
        result = Bₑ(t, vertices)
        xVector[index] = result.x
        yVector[index] = result.y
        index += 1
    end

    return xVector, yVector

end

# Construct a Bezier curve that is linearly interpolated.
# Points: The points the Bezier curve is made of.
# nSamples:  The amount of samples used to construct the curve (higher = increased resolution).
function BezierInterpolated(vertices::Vector{Vertex2D}, nSamples::Real, bezierSamples::Real)

    # Create the uninterpolated bezier curve.
    bezierX, bezierY = Bezier(vertices, bezierSamples)

    # Has to be interpolated so that the SDR can actually use the samples.
    linInterpolation = LinearInterpolation(bezierX, bezierY)
    sampledX = -1:1/(nSamples-1):1
    return Float32.(linInterpolation(sampledX)), sampledX

end

# Create an interpolated Bezier frequency curve.
# The points (-1,-1), (0,0) and (1,1) are always given, and only
# have to provide the first half of the waveforms' vertices.
function BezierFrequencies(vertices::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real=0)

    # If no value passed, default to the amount of samples.
    if(bezierSamples==0) 
        bezierSamples = nSamples
    end

    # Setup the vertices.
    totalVertices = 3 + length(vertices)*2
    waveformVertices = Vector{Vertex2D}(undef, totalVertices)
    middleVetex = ceil(Int32, totalVertices/2)
    waveformVertices[1] = Vertex2D(-1,-1)
    waveformVertices[totalVertices] = Vertex2D(1,1)
    waveformVertices[middleVetex] = Vertex2D(0,0)

    # First half of the waveforms passed vertices.
    index = 1
    for i in 2:1:(middleVetex-1)
        waveformVertices[i] = vertices[index]
        index += 1
    end

    # Second half of the waveforms passed vertices.
    index = 1
    for i in (totalVertices-1):-1:(middleVetex+1)
        waveformVertices[i] = -1 * vertices[index]
        index += 1
    end

    # Calculate the interpolated Bezier curve, given the vertices.
    return BezierInterpolated(waveformVertices, nSamples, bezierSamples)

end

# Create an interpolated Bezier frequency curve based on the parameters.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierFreqienciesParametric(parameters::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real = 0)

    # If no value passed, default to the amount of samples.
    if(bezierSamples==0) 
        bezierSamples = nSamples
    end

    # Calculate the amount of points for the curve.
    nPoints = length(parameters)

    # Check if parameters vector is correct size.
    if(length(parameters) != nPoints)
        println("Incorrect parameters vector length.")
        return 0
    end

    # Create the vertices from the paramters.
    vertices = Vector{Vertex2D}(undef, nPoints)
    baseVertex = Vertex2D(-1,-1)
    for i in 1:1:nPoints
        vertices[i] = (1 - parameters[i]) * baseVertex
        baseVertex = vertices[i]
    end

    # Create the waveform from the paramters.
    return BezierFrequencies(vertices, nSamples, bezierSamples = bezierSamples)

end

# Calculate the phase vector for the type of Bezier frequency curve.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierPhaseParametric(parameters::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real = 0, rtol::Real = 1e-3)

    return 

end

# Create a signal with a Bezier NLFM scheme, based on the parameters.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierSignalParametric(parameters::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real = 0)

    # If no value passed, default to the amount of samples.
    if(bezierSamples==0) 
        bezierSamples = nSamples
    end

    # Calculate the amount of points for the curve.
    nPoints = length(parameters)

    # Check if parameters vector is correct size.
    if(length(parameters) != nPoints)
        println("Incorrect parameters vector length.")
        return 0
    end

    # Create the vertices from the paramters.
    vertices = Vector{Vertex2D}(undef, nPoints)
    baseVertex = Vertex2D(-1,-1)
    for i in 1:1:nPoints
        vertices[i] = (1 - parameters[i]) * baseVertex
        baseVertex = vertices[i]
    end

    # Create the waveform from the paramters.
    return BezierWaveform(vertices, nSamples, bezierSamples = bezierSamples)

end

# Create a Bezier waveform plane by varing one point, and return the SLL plane.
# The plane can only be represented in 3D when there is one point being varied
# in 2 dimensions.
# BW: the bandwidth of the signal.
# fs: the sampling frequency used to sample the signal.
# resolution: The resolution of the plane in the 2 dimensions.
# waveformNSamples: the amount of samples in the waveform.
# bezierNSamples: the amount of samples used in the interpolation.  More = better accuracy.
function BezierWaveformSLLPlane(BW::Real, fs::Real, planeResolution::Real, waveformNSamples::Real; plot::Bool = true, bezierNSamples::Real = 0, lobeCount::Real = 3,
                                title = "Bezier Plane")
    
    # If no value passed, default to the amount of samples.
    if(bezierNSamples==0) 
        bezierNSamples = waveformNSamples
    end

    # The paramters iterated over.
    parameterVec = collect(0:1/(planeResolution-1):1)

    # Iterate over the parameter in both dimensions.
    SLLVec = Vector{Float32}(undef, planeResolution^2)
    SLLIndex = 1
    for x in parameterVec
        for y in parameterVec
            vertex = Vertex2D(x, y)
            waveform, NULL = BezierSignalParametric([vertex], nSamples, bezierSamples = bezierNSamples)
            mf = plotMatchedFilter(0, waveform, [], fs, plot = false)
            SLLVec[SLLIndex] = calculateSideLobeLevel(mf, lobeCount)
            SLLIndex += 1
        end
    end
    SLLVec = reshape(SLLVec, (planeResolution, planeResolution))

    # Plotting.
    if plot
        ax = Axis3(figure[1, 1], xlabel = "P1", ylabel = "P2",zlabel = "SLL (dB)", title = title)
        ax.azimuth = pi/2 - pi/4
        surface!(parameterVec, parameterVec, SLLVec)
        xlims!(0, 1)
        ylims!(0, 1)
        zlims!(minimum(SLLVec), maximum(SLLVec))        
    end
end