# Iterates over the doppler maps so that they can easily be viewed.

# Modules.
using JLD2
include("../Utilities/MakieGL/PlotUtilities.jl")

# Frames folder to use.
frames_folder = "10-Frames"

# Start Makie.
figure = Figure()
Axis(figure[1,1])
display(figure)

# Iterate folders.
data_dir = "Data/" * frames_folder * "/EntireDopplerMap/"
folders = readdir(data_dir)
for folder in folders
    
    # Iterate files.
    files = readdir(data_dir * folder * "/")
    for file in files
        
        data = load(data_dir * folder * "/" * file) 
        doppler = data["Doppler FFT Matrix"]
        distance = data["Distance"]
        velocity = data["Velocity"]
        heatmap!(figure[1, 1], distance, velocity, abs.(doppler), colorrange = [0, 13])
        text!(distance[1] , velocity[1], text = "File: " * file)
        sleep(2)

    end
end
