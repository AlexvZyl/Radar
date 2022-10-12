using Flux
using CUDA
include("Utilities.jl")

# Load the doppler frames from the folder into a vector.
function load_doppler_frames(folder::String)
    map_dir = get_directories(folder)[3]
    files = get_all_files(map_dir, true)  
    doppler_frames = Vector{Vector{AbstractMatrix}}()
    for file in files
        push!(doppler_frames, load(file)["Doppler FFT Frames"])
    end
    return doppler_frames
end


# Load all of the frames.
folders = get_elevated_folder_list()
frames = load_doppler_frames.(folders)
# Type:
# Vector                        - Folders (classes)
#   Vector                      - Iterations
#       Vector                  - Frames
#           AbstractMatrix      - Frame
