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
frame_counts = [ 1 ]
frame_counts = [ 1, 5, 10, 15, 20 ]
folders = get_elevated_folder_list()
files = String[]

# Pipeline.
for frame_count in frame_counts
    for folder in folders
        # raw_to_doppler_map(folder, files)
        # cluster_dopplermaps(folder, files)
        # label_clusters(folder, files)
        generate_frames(folder, files, frame_count = frame_count, frame_overlap_ratio = 0.5)
        # extract_targets(folder, files)
        # extract_features(folder, files)
    end
end
