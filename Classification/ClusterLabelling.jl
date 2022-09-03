# Takes the doppler frames and clustering information and extracts the relevant targets.
# This requires a user to provdide input.

# Modules.
include("DopplerMap.jl")
using JLD
using Base.Threads

# File data.
folder = "Test"
file_prefix =  "/B210_SAMPLES_" * folder * "_"
file_extension = ".jld"
parent_dir = "/home/alex/GitHub/Masters-Julia/Classification/Data/"
cluster_dir = parent_dir * "DopplerClustering/" * folder 
frames_dir = parent_dir * "DopplerFrames/" * folder
map_dir = parent_dir * "EntireDopplerMap/" * folder
all_files = true
# If all files is not true we have to use specific files.
selected_files = ["001", "002"]

# Get all of the files in the directory.
if all_files
    selected_files = readdir(cluster_dir)
end

# The user now has to identify the cluster that has the target for each doppler map.

