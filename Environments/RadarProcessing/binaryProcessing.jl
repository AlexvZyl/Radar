# Drawing engine.
using GLMakie
# Set Makie theme.
set_theme!(theme_dark())



radarData = Array{Float32}(undef, 10, 10);

open("RadarData-Binary\\Rhino\\Capture_1000.bin");
read!("RadarData-Binary\\Rhino\\Capture_1000.bin", radarData);
