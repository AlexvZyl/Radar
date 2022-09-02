# Modules.
using JLD
include("DopplerMap.jl")

# Meta data.
folder 			= "Test"
file_number 	= "012"

# Fixed metdata.
path 			= "/home/alex/GitHub/Masters-Julia/Classification/Data/DopplerFrames/"
file_prefix 	= "/B210_SAMPLES_" * folder * "_"
file            = path * folder * file_prefix * file_number * ".jld"

# Load the file.
file_data       = load(file)
doppler_frames  = file_data["Doppler FFT Frames"]
distance_vector = file_data["Distance"]
velocity_vector = file_data["Velocity"]

# Render.
animate(doppler_frames, distance_vector, velocity_vector, snr_threshold = 10)
