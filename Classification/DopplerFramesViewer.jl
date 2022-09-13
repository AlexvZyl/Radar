# Modules.
using JLD
using Clustering
include("DopplerMap.jl")

# Meta data.
folder 			 = "Test"
file_number 	 = "010"

# Fixed metdata.
path 			 = "/home/alex/GitHub/Masters-Julia/Classification/Data/"
file_prefix 	 = "/B210_SAMPLES_" * folder * "_"

# Load doppler frames.
frames_file      = path * "DopplerFrames/" * folder * file_prefix * file_number * ".jld"
file_data        = load(frames_file)
doppler_frames   = file_data["Doppler FFT Frames"]
distance_vector  = file_data["Distance"]
velocity_vector  = file_data["Velocity"]

# Load doppler clustering.
clusters_file    = path * "DopplerClustering/" * folder * file_prefix * file_number * ".jld"
clusters_file_data = load(clusters_file) 
doppler_clusters = clusters_file_data["Clustering Result"]
adjacency_matrix = clusters_file_data["Adjacency Matrix"]

# Render.
animate(doppler_frames, distance_vector, velocity_vector, snr_threshold = 0, clusters = doppler_clusters, adjacency_matrix = adjacency_matrix)
