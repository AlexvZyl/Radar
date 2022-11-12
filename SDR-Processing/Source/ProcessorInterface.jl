# Modules.
include("../../Utilities/MakieGL/MakieGL.jl")
include("PostProcessor.jl")

update_theme!(
	font = "Latin Modern Math", # Linux.
)

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

# Data for presenting the pipeline in the thesis.
folder  = "ThesisPipeline"
# Normal TX.
file_name = "Direct_Doppler_Map_Clutter.pdf"
file_number = "008" 

# Display processing.
figure = process_intput(folder, file_number, snr_min = 0, pulsesToLoad = 0)
# display(figure)
save(file_name, figure)
