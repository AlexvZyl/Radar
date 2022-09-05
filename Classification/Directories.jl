# Get the paths of the directories to be used for the data.
# These directories are used by a few files and this makes it easier to work with.
function get_directories(folder::String)
    parent_dir = "/home/alex/GitHub/Masters-Julia/Classification/Data/"
    cluster_dir = parent_dir * "DopplerClustering/" * folder * "/"
    frames_dir = parent_dir * "DopplerFrames/" * folder * "/"
    map_dir = parent_dir * "EntireDopplerMap/" * folder * "/"
    return map_dir, cluster_dir, frames_dir
end

# Create a file name including the path.
function get_file_path(dir::String, file::String)
    return dir * file 
end

# Craete the file name without a path.
function get_file_name(folder::String, number::String; extension::String = ".jld")
    return "B210_SAMPLES_" * folder * "_" * number * extension
end
