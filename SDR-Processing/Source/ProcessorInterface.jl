# Modules.
include("PostProcessor.jl")

# Input.
# folder = "WalkingAway"
# folder = "WalkingTowards"
# folder = "WalkingAway_Elevated_90deg"
# folder = "WalkingTowards_Elevated_90deg"
folder = "JoggingTowards_Elevated_90deg"
# folder = "JoggingTowards"
# folder = "JoggingAway"
file_number = "010"

# Display processing.
process_intput(folder, file_number, snr_min = 0)

