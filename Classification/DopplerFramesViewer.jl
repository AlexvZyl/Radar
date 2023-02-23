using GLMakie: dist
# Modules.
using JLD
using Clustering
include("DopplerMap.jl")

# Meta data.
frames           = "1-Frames/"
folder 			 = "JoggingAway_Elevated_90deg_Stick"
file_number 	 = "001"

# Fixed metdata.
path 			 = "/home/alex/GitHub/Radar/Classification/Data/"
file_prefix 	 = "/B210_SAMPLES_" * folder * "_"

# Load doppler frames.
frames_file      = path * "DopplerFrames/" * frames * folder * file_prefix * file_number * ".jld"
file_data        = load(frames_file)
doppler_frames   = file_data["Doppler FFT Frames"]
distance_vector  = file_data["Distance"]
velocity_vector  = file_data["Velocity"]

d = length(distance_vector)
v = length(velocity_vector)
println(length(doppler_frames))
println("Range bins: ", d)
println("Velocity bins: ", v)
display(velocity_vector)
display(distance_vector)

return 0

# Render.
animate(doppler_frames, distance_vector, velocity_vector, snr_threshold = 0)
