# Takes the doppler frames and clustering information and extracts the relevant targets.
# This requires a user to provdide input.

# Modules.
include("DopplerMap.jl")
include("Directories.jl")
using JLD
using Base.Threads

# File data.
folder = "Test"
map_dir, cluster_dir, frames_dir = get_directories(folder)
all_files = true
# If all files is not true we have to use specific files.
selected_files = [
    "001", 
    "002"
]

# Get all of the files in the directory.
if all_files
    selected_files = readdir(cluster_dir)
end

# The user now has to identify the cluster that has the target for each doppler map.
for file in all_files
    cluster_file_data = load(cluster_dir * file)
    doppler_file_data = load(map_dir * file)
    display(cluster_file_data)
    display(doppler_file_data)
end
