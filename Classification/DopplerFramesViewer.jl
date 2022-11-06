# Modules.
using JLD
using Clustering
include("DopplerMap.jl")

# Meta data.
folder 			 = "JoggingAway_Elevated_90deg_Stick"
file_number 	 = "001"

# Fixed metdata.
path 			 = "/home/alex/GitHub/Radar/Classification/Data/"
file_prefix 	 = "/B210_SAMPLES_" * folder * "_"

# Load doppler frames.
frames_file      = path * "DopplerFrames/" * folder * file_prefix * file_number * ".jld"
file_data        = load(frames_file)
doppler_frames   = file_data["Doppler FFT Frames"]
distance_vector  = file_data["Distance"]
velocity_vector  = file_data["Velocity"]

# Render.
animate(doppler_frames, distance_vector, velocity_vector, snr_threshold = 0)
