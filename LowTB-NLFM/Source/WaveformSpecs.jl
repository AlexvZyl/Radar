include("Utilities.jl")

#------------------------
# General specifications.
#------------------------

# High TBP.
# BW = 50e6
# fs = 110e6
# t_i = 50e-6

# Low TBP (66)
# BW = 20e6
# t_i = 3.3e-6
# fs = BW * 2.5

# High TBP (1000)
# t_i = 25e-6
# BW = 60e6
# fs = BW * 2.5

# Copmpared to paper.
# BW = 2e6
# fs = BW * 2.5
# t_i = 75e-6

# For measurements.
BW = 20e6
deadzone = 50
fs = 22e6
println("Distance: ", deadzone)
t_i = distanceToTime(deadzone)
println("Time: ", t_i) 

# Ensure odd number of samples.
nSamples = ceil(Int, fs * t_i)
if nSamples % 2 == 0
    nSamples += 1
end

#-----------------------
# Bezier specifications.
#-----------------------

sampleIterations = 14
optimIterations = 100
resolution = 10
yRange = [-2,2]
xRange = [-2,2]
maxSearchValue = 20
particles = 100
points = 4
# Setup coords cap.
coordsCap = [ [], [] ]
for i in 1:points*2
    append!(coordsCap[1], -maxSearchValue)
    append!(coordsCap[2],  maxSearchValue)
end

#----------------------
# Logit Specifications.
#----------------------

# SLL VS TBP #
# fs = 120e6
# tiRange = [60e-6, 60e-6]
# bwRange = [0.01e6, 50e6]
# parameterRange = [0, 6] 
# parameterSamples = 50
# tbSamples = 50
# lobeCount = 3

#---------------------------
# Hyperbolic specifications.
#---------------------------

# SLL VS TBP #
# fs = 120e6
# tiRange = [60e-6, 60e-6]
# bwRange = [0.01e6, 50e6]
# parameterRange = [0, 15] 
# parameterSamples = 200
# tbSamples = 50
# lobeCount = 100
