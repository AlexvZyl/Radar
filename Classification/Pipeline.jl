# Module to run the entire processing pipeline.
# This is to prevent having to run each of the files seperately.

# Modules.
include("RawToDopplerMap.jl")
include("DBSCAN.jl")
include("ClusterLabelling.jl")
include("DopplerFramesGenerator.jl")
include("ExtractTargets.jl")
include("FeatureExtraction.jl")
include("Utilities.jl")

# Data.
# folders = [ "JoggingAway_Elevated_90deg",  "JoggingTowards_Elevated_90deg", "WalkingAway_Elevated_90deg",  "WalkingTowards_Elevated_90deg" ]
folders = get_elevated_folder_list()
files = String[]

# Pipeline.
for folder in folders
    # raw_to_doppler_map(folder, files)
    # cluster_dopplermaps(folder, files)
    # label_clusters(folder, files)
    generate_frames(folder, files)
    # extract_targets(folder, files)
    # extract_features(folder, files)
end
