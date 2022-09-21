# Module to run the entire processing pipeline.
# This is to prevent having to run each of the files seperately.

# Modules.
include("RawToDopplerMap.jl")

# Data.
folder = "Test"
files = String[  ]

# Pipeline.
raw_to_doppler_map(folder, files)
