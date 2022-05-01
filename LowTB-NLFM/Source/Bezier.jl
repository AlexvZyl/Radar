using Interpolations
include("Vertex.jl")

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

# Create a single vertex for the Bezier curve, using the explicit form.\
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
    
    # println(vertex)
    return vertex

end

# Construct a Bezier curve.
# Points: The points the Bezier curve is made of.
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
function BezierInterpolated(vertices::Vector{Vertex2D}, nSamples::Real)

    # Create the uninterpolated bezier curve.
    bezierX, bezierY = Bezier(vertices, nSamples)

    # Has to be interpolated so that the SDR can actually use the samples.
    linInterpolation = LinearInterpolation(bezierX, bezierY)
    sampledX = -1:1/(nSamples-1):1
    return linInterpolation(sampledX), sampledX

end