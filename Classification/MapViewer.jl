include("DopplerMap.jl")
include("Utilities.jl")
using JLD

# View a specific doppler map stored in a .JLD file.
# Creates new figure if one does not already exist.
# @returns figure.
function view_doppler_map(path::String; existing_figure = false)

    file_data = load(path)
    doppler_matrix   = file_data["Doppler FFT Matrix"]
    distance_vector  = file_data["Distance"]
    velocity_vector  = file_data["Velocity"]
    figure = plot(doppler_matrix, distance_vector, velocity_vector, existing_figure = existing_figure)
    text!(distance_vector[1] , velocity_vector[1], text = basename(path))
    return figure

end

# View, prediodically, all of the Doppler maps inside the specified folder.
function view_doppler_maps(folders; sleep_time = 6)

    figure = false
    for folder in folders 

        folders_dir = get_directories(folder)[1]
        files = get_all_files(folders_dir, true)
        for file in files
            figure = view_doppler_map(file, existing_figure = figure)
            display(figure)
            sleep(sleep_time)
        end

    end

end

# Run script.
# view_doppler_maps(get_janke_folder_list())
view_doppler_maps(get_elevated_folder_list(), sleep_time = 1)
