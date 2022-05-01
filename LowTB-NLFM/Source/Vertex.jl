# ------------------- #
#  V E R T E X   2 D  #
# ------------------- #

mutable struct Vertex2D 
    x::Float32;
    y::Float32;
end

# ----------------- #
#  A D D I T I O N  #
# ----------------- #

import Base.+
(+)(val::Real, vertex::Vertex2D)          = Vertex2D(vertex.x + val, vertex.y + val)
(+)(vertex::Vertex2D, val::Real)          = (+)(val, vertex)
(+)(val::Vector, vertex::Vertex2D)        = Vertex2D(vertex.x + val[1], vertex.y + val[2])
(+)(vertex::Vertex2D, val::Vector)        = (+)(val, vertex)
(+)(vertex1::Vertex2D, vertex2::Vertex2D) = Vertex2D(vertex1.x + vertex2.x, vertex1.y + vertex2.y)

# ----------------------- #
#  S U B T R A C T I O N  #
# ----------------------- #

import Base.-
(-)(val::Real, vertex::Vertex2D)          = Vertex2D(val - vertex.x, val - vertex.y)
(-)(vertex::Vertex2D, val::Real)          = Vertex2D(vertex.x - val, vertex.y - val)
(-)(val::Vector, vertex::Vertex2D)        = Vertex2D(val[1] - vertex.x, val[2] - vertex.y)
(-)(vertex::Vertex2D, val::Vector)        = Vertex2D(vertex.x - val[1], vertex.y - val[2])
(-)(vertex1::Vertex2D, vertex2::Vertex2D) = Vertex2D(vertex1.x - vertex2.x, vertex1.y - vertex2.y)

# ----------------------------- #
#  M U L T I P L I C A T I O N  #
# ----------------------------- #

import Base.*
(*)(val::Real, vertex::Vertex2D)          = Vertex2D(vertex.x * val, vertex.y * val)
(*)(vertex::Vertex2D, val::Real)          = (*)(val, vertex)
(*)(val::Vector, vertex::Vertex2D)        = Vertex2D(vertex.x * val[1], vertex.y * val[2])
(*)(vertex::Vertex2D, val::Vector)        = (*)(val, vertex)
(*)(vertex1::Vertex2D, vertex2::Vertex2D) = Vertex2D(vertex1.x * vertex2.x, vertex1.y * vertex2.y)

# ----------------- #
#  D I V I S I O N  #
# ----------------- #

import Base./
(/)(val::Real, vertex::Vertex2D)          = Vertex2D( val / vertex.x, val / vertex.y)
(/)(vertex::Vertex2D, val::Real)          = Vertex2D(vertex.x / val,  vertex.y / val)
(/)(val::Vector, vertex::Vertex2D)        = Vertex2D(val[1] / vertex.x, val[2] / vertex.y)
(/)(vertex::Vertex2D, val::Vector)        = Vertex2D(vertex.x / val[1], vertex.y / val[2])
(/)(vertex1::Vertex2D, vertex2::Vertex2D) = Vertex2D(vertex1.x / vertex2.x, vertex1.y / vertex2.y)

# ------- #
#  E O F  #
# ------- #