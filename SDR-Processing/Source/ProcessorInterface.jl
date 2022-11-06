# Modules.
include("PostProcessor.jl")

# Input.
# folder = "WalkingAway"
# folder = "WalkingTowards"
# folder = "WalkingAway_Elevated_90deg"
folder = "WalkingAway_Elevated_90deg_Stick"
# folder = "WalkingTowards_Elevated_90deg"
folder = "JoggingTowards_Elevated_90deg"
# folder = "JoggingTowards"
# folder = "JoggingAway"
# folder = "Clutter"
file_number = "009"

# Display processing.
process_intput(folder, file_number, snr_min = 0)
