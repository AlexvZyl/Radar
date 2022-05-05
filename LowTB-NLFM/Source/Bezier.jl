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
function Bezier(vertices::Vector{Vertex2D}, nSamples::Real; xRange::Vector = [-1,1])

    # Setup the vectors.
    tVector = 0:1/(nSamples-1):1
    xVector = Vector{Float32}(undef, nSamples)
    yVector = Vector{Float32}(undef, nSamples)

    # Loop over the samples. 
    index = 1
    for t in tVector
        # result = Bₚ(t, vertices)
        result = Bₑ(t, vertices)
        if result.x >= xRange[1] && result.x <= xRange[2]
            xVector[index] = result.x
            yVector[index] = result.y
            index += 1
        end
    end

    return xVector[1:index-1], yVector[1:index-1]

end

# Construct a Bezier curve that is linearly interpolated.
# Points: The points the Bezier curve is made of.
# nSamples:  The amount of samples used to construct the curve (higher = increased resolution).
function BezierInterpolated(vertices::Vector{Vertex2D}, nSamples::Real, bezierSamples::Real)

    # Create the uninterpolated bezier curve.
    bezierX, bezierY = Bezier(vertices, bezierSamples)

    # Has to be interpolated so that the SDR can actually use the samples.
    linInterpolation = LinearInterpolation(Interpolations.deduplicate_knots!(bezierX, move_knots = true), bezierY)
    sampledX = -1:2/(nSamples-1):1
    return Float32.(linInterpolation(sampledX))

end

# Create an interpolated Bezier frequency curve.
# The points (-1,-1), (0,0) and (1,1) are always given, and only
# have to provide the first half of the waveforms' vertices.
function BezierFrequencies(vertices::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real=0, BW::Real = 2)

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
    return BezierInterpolated(waveformVertices, nSamples, bezierSamples) .* Float32(BW/2)

end

# Create an interpolated Bezier frequency curve based on the parameters.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierFreqienciesParametric(parameters::Vector{Vertex2D}, nSamples::Real; bezierSamples::Real = 0, BW::Real = 2)

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
    return BezierFrequencies(vertices, nSamples, bezierSamples = bezierSamples, BW = BW)

end

# Calculate the phase vector for the type of Bezier frequency curve.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierPhaseParametric(parameters::Vector{Vertex2D}, fs::Real, nSamples::Real, BW::Real; bezierSamples::Real = 0, rtol::Real = 1e-3)

    # Calculate the frequencies.
    bezierFreq = BezierFreqienciesParametric(parameters, nSamples, BW = BW, bezierSamples = bezierSamples)
    
    # Setup interpolation.
    duration = nSamples / fs
    timevec = 0:duration/(nSamples-1):duration
    bezierFreqInterpol = LinearInterpolation(timevec, bezierFreq)
    # Utility that gets the frequency at the given time (for quadgk).
    function GetBezierFreq(time::Real, bezierFreqInterpol) 
        return bezierFreqInterpol(time)
    end
    
    # Calculate the phase.
    phase = Vector{Float32}(undef, nSamples)
    phase[1] = 0
    phase[nSamples] = 0
    for i in 2:1:(nSamples-1)
        phase[i], err =  quadgk(t -> GetBezierFreq(t, bezierFreqInterpol), timevec[1], timevec[i], rtol = rtol)
    end

    return phase
end

# Create a signal with a Bezier NLFM scheme, based on the parameters.
# nPoints: The amount of points used in the Bezier waveform.  This does not include 
# the first, last and middle vertex.  Thus, 0 means three points.
# parameters: A vector containing the parameter for each of the points.  Has to be of size nPoints, and range from(0,1).
function BezierSignalParametric(parameters::Vector{Vertex2D}, fs::Real, nSamples::Real, BW::Real; bezierSamples::Real = 0)

    # Create the signal from the phase vector.
    phase = BezierPhaseParametric(parameters, fs, nSamples, BW, bezierSamples = bezierSamples)
    return exp.(im * phase * π)

end

# Create a Bezier waveform plane by varing one point, and return the SLL plane.
# The plane can only be represented in 3D when there is one point being varied
# in 2 dimensions.
# BW: the bandwidth of the signal.
# fs: the sampling frequency used to sample the signal.
# resolution: The resolution of the plane in the 2 dimensions.
# waveformNSamples: the amount of samples in the waveform.
# bezierNSamples: the amount of samples used in the interpolation.  More = better accuracy.
function BezierSurface(BW::Real, fs::Real, planeResolution::Real, waveformNSamples::Real; plot::Bool = true, bezierNSamples::Real = 0, lobeCount::Real = 3,
                       title = "Bezier Surface", xRange = [0,1], yRange = [0,1], MLW::Bool = false, dB::Real = 0, azimuth::Real = pi/2 - pi/4, elevation::Real = pi/4)
    
    # If no value passed, default to the amount of samples.
    if(bezierNSamples==0) 
        bezierNSamples = waveformNSamples
    end

    # The paramters iterated over.
    xSize = xRange[2] - xRange[1]
    xParameterVec = xRange[1]:xSize/(planeResolution-1):xRange[2]
    ySize = yRange[2] - yRange[1]
    yParameterVec = yRange[1]:ySize/(planeResolution-1):yRange[2]

    # Iterate over the parameter in both dimensions.
    data = Vector{Float32}(undef, planeResolution^2)
    index = 1
    for x in xParameterVec
        for y in yParameterVec
            vertex = Vertex2D(x, y)
            waveform = BezierSignalParametric([vertex], fs, nSamples, BW, bezierSamples = bezierNSamples)
            mf = plotMatchedFilter(0, waveform, [], fs, plot = false)
            if MLW
                data[index] = calculateMainLobeWidth(mf, dB = dB) / fs
            else 
                data[index] = calculateSideLobeLevel(mf, lobeCount)
            end
            index += 1
        end
    end

    # Calculate the width in Nyqsuit samples.
    if MLW
        data *= BW
    end

    val, index = findmin(data)
    x = ceil(Int, index / planeResolution) 
    y = (index % planeResolution)

    if MLW
        println("Min Main Lobe Width (samples): ", val)
    else
        println("Min SLL: ", val, " dB")
    end
    println("Min Index = [ x:", x, " , y:", y, " ]")
    println("Min Vertex = [ x:", xParameterVec[x], " , y:", yParameterVec[y], " ]")
    
    # Plotting.
    if plot
        data = transpose(reshape(data, (planeResolution, planeResolution)))
        zaxis = "PSL (dB)"
        title = "Bézier SLL Performance Surface"
        if MLW
            zaxis = "Nyquist Samples"
            title = "Bézier Main Lobe Width Performance Surface"
        end
        ax = Axis3(figure[1, 1], xlabel = "X", ylabel = "Y", zlabel = zaxis, title = title)
        ax.azimuth = azimuth
        ax.elevation = elevation
        surface!(xParameterVec, yParameterVec, data)
        xlims!(xRange[1], xRange[2])
        ylims!(yRange[1], yRange[2]*1.1)
        if MLW
            zlims!(0, maximum(data))        
        else
            zlims!(-40, 0)        
        end
    end
end


function BezierContour(figure, BW::Real, fs::Real, planeResolution::Real, waveformNSamples::Real; plot::Bool = true, bezierNSamples::Real = 0, lobeCount::Real = 3,
                       title = "Bézier Contour", xRange = [0,1], yRange = [0,1], dB::Real = 0, lobeWidthContourCount::Real = 5, sideLobeContourCount::Real = 5)

    # If no value passed, default to the amount of samples.
    if(bezierNSamples==0) 
        bezierNSamples = waveformNSamples
    end

    # The paramters iterated over.
    xSize = xRange[2] - xRange[1]
    xParameterVec = xRange[1]:xSize/(planeResolution-1):xRange[2]
    ySize = yRange[2] - yRange[1]
    yParameterVec = yRange[1]:ySize/(planeResolution-1):yRange[2]

    # Iterate over the parameter in both dimensions.
    lobeWidthData = Vector{Float32}(undef, planeResolution^2)
    sideLobeData = Vector{Float32}(undef, planeResolution^2)
    index = 1
    for x in xParameterVec
        for y in yParameterVec
            vertex = Vertex2D(x, y)
            waveform = BezierSignalParametric([vertex], fs, nSamples, BW, bezierSamples = bezierNSamples)
            mf = plotMatchedFilter(0, waveform, [], fs, plot = false)
            lobeWidthData[index] = calculateMainLobeWidth(mf, dB = dB) / fs
            sideLobeData[index] = calculateSideLobeLevel(mf, lobeCount)
            index += 1
        end
    end

    # Calculate the width in Nyqsuit samples.
    lobeWidthData *= BW
    
    # Plotting.
    if plot 
        lobeWidthData = transpose(reshape(lobeWidthData, (planeResolution, planeResolution)))
        sideLobeData = transpose(reshape(sideLobeData, (planeResolution, planeResolution)))
        lobeWidthMax = maximum(lobeWidthData)
        if dB == 0
            title = string(title, " (0-0 MLW)")
            MLWmax = 50
            levelsMLW = 0:5:MLWmax
        else
            title = string(title, " (", string(dB), " dB MLW)")
            MLWmax = 5
            levelsMLW = 0:0.25:MLWmax
        end
        ax = Axis(figure[1, 1], xlabel = "X", ylabel = "Y", title = title)
        co = contourf!(xParameterVec, yParameterVec, sideLobeData, levels = sideLobeContourCount, extendhigh = :auto)
        Colorbar(figure[1, 2], co, label = "PSL (dB)", size = 32)
        translate!(co, 0, 0, -100)
        mlwColormap = :bone
        co2 = contour!(xParameterVec, yParameterVec, lobeWidthData, levels=levelsMLW, linewidth = 5, colormap  = mlwColormap)
        Colorbar(figure[1, 3], limits = (0,MLWmax) , label = "MLW (Nyquist samples)", size = 32, categorical = true, colormap = cgrad(mlwColormap, length(levelsMLW), categorical = true))
        xlims!(xRange[1], xRange[2])
        ylims!(yRange[1], yRange[2])
    end

end

function BezierParetoFront(figure, BW::Real, fs::Real, planeResolution::Real, waveformNSamples::Real; plot::Bool = true, bezierNSamples::Real = 0, lobeCount::Real = 3,
                           title = "Bézier Pareto Front", xRange = [0,1], yRange = [0,1], dB::Real = 0, lobeWidthContourCount::Real = 5, sideLobeContourCount::Real = 5,
                           nPoints::Real = 1)

    # If no value passed, default to the amount of samples.
    if(bezierNSamples==0) 
        bezierNSamples = waveformNSamples
    end

    # The paramters iterated over.
    xSize = xRange[2] - xRange[1]
    xParameterVec = xRange[1]:xSize/(planeResolution-1):xRange[2]
    ySize = yRange[2] - yRange[1]
    yParameterVec = yRange[1]:ySize/(planeResolution-1):yRange[2]

    # Iterate over the parameter in both dimensions.
    lobeWidthData = Vector{Float32}(undef, planeResolution^(2*nPoints))
    sideLobeData = Vector{Float32}(undef, planeResolution^(2*nPoints))
    index = 1

    # Iterate frst vertex.
    for x1 in xParameterVec
    for y1 in yParameterVec

    # # Iterate second vertex.
    # for x2 in xParameterVec
    # for y2 in yParameterVec

    # # Iterate third vertex.
    # for x3 in xParameterVec
    # for y3 in yParameterVec

    # # Iterate third vertex.
    # for x4 in xParameterVec
    # for y4 in yParameterVec

            vertex1 = Vertex2D(x1, y1)
            # vertex2 = Vertex2D(x2, y2)
            # vertex3 = Vertex2D(x3, y3)
            # vertex4 = Vertex2D(x4, y4)
            # vertices = [vertex1, vertex2, vertex3, vertex4]
            vertices = [ vertex1 ]
            waveform = BezierSignalParametric(vertices, fs, nSamples, BW, bezierSamples = bezierNSamples)
            mf = plotMatchedFilter(0, waveform, [], fs, plot = false)
            lobeWidthData[index] = calculateMainLobeWidth(mf, dB = dB) / fs
            sideLobeData[index] = calculateSideLobeLevel(mf, lobeCount)
            index += 1

    # end
    # end
    # end
    # end
    # end
    # end
    end
    end

    # Calculate the width in Nyqsuit samples.
    lobeWidthData *= BW

    ax = Axis(figure[1, 1], xlabel = "PSL (dB)", ylabel = "MLW (samples)", title = title)
    ax.xreversed = true
    # ax.yreversed = true
    plotOrigin(ax)
    scatter!(sideLobeData, lobeWidthData, color = :blue, markersize = 15)
    vlines!(ax, -36.8, color = :black, linewidth=5, linestyle = :dash, label = "Optimal Logit")
	hlines!(ax, 12.5, color = :black, linewidth=5, linestyle = :dash)
    axislegend(ax)
    xlims!(0, -40)
    ylims!(0, 100)

end