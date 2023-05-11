include("../Utilities/Processing/ProcessingHeader.jl")
include("DopplerMap.jl")
include("Utilities.jl")
using JLD2

const path 	= "/home/alex/Repositories/SDR-Interface/build/Data/"

# Take the raw data, syncronise it, and save the raw data again.
function sync_raw_data(folder::String, file::String)
    
    # File data.
    file_bin 		= remove_extension(file) * ".bin"
    file_txt		= remove_extension(file) * ".txt"

    # Get metadata.
    meta_data = load_meta_data(path * folder * "/" * file_txt)

    # Get the data from the file.
    raw_data = loadDataFromBin(path * folder * "/" * file_bin, meta_data, pulsesToLoad = 0) 
    tx_signal = generate_tx_signal(meta_data)

    # Sync the signal.
    pc_signal = pulseCompression(tx_signal, raw_data)
    sync_index = get_sync_index(pc_signal, meta_data, pulses_to_search = 2)
    pc_signal = Nothing # Try to save on RAM.
    raw_data = sync_signal(raw_data, sync_index, meta_data) 

    # Now save the synced data.
    save("Data/SyncedRawData/" * folder * "/" * remove_extension(file) * ".jld", 
         "Synced Raw Data", raw_data)

end

# Sync all of the files.
folders = get_elevated_folder_list()
# JDL does not multi thread nicely... :(
for folder in folders
    files = get_all_files(path * folder, false)
    for file in files
        sync_raw_data(folder, file)
    end
end
