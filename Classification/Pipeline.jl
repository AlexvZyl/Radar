# Module to run the entire processing pipeline.
# This is to prevent having to run each of the files seperately.

# Modules.
include("RawToDopplerMap.jl")
include("DBSCAN.jl")
include("ClusterLabelling.jl")
include("DopplerFramesGenerator.jl")
include("ExtractTargets.jl")

# Data.
folder = "Test"
files = String[ "010", "011", "012" ]

# Pipeline.
raw_to_doppler_map(folder, files)
cluster_dopplermaps(folder, files)
# label_clusters(folder, files)
generate_frames(folder, files)
extract_targets(folder, files)
