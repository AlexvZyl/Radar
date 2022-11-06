# Iterates over the doppler maps so that they can easily be viewed.

# Modules.
using JLD2
include("../Utilities/MakieGL/PlotUtilities.jl")

# Start Makie.
figure = Figure()
Axis(figure[1,1])
button = Makie.Button(figure[2,1], label = "Continue", tellwidth = false)
display(figure)

# Button callback.
condition = Threads.Condition()
on(button.clicks) do val
    lock(condition)
    notify(condition, val)
    unlock(condition)
end

# Iterate folders.
data_dir = "Data/EntireDopplerMap/"
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

        # Wait for the button to be pressed.
        lock(condition)
        _val = wait(condition)
        unlock(condition)

    end
end
