include("Multipath.jl")

# Scene parameters.
hr = 3
R = 75
f_range = 900e6:100e6:1.1e9

# Flat earth model.
# plot_lobe_structure(hr, R, f_range)

# Flat earth model heatmap.
R_range = 10:0.1:100
ht_range = 0:0.025:10
height_target = 1
hr = 3
hr_range = 0:0.001:2
f = 1.1e9
dB = true
plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
# plot_multipath_heatmap_flat_earth_vary_target(R_range, ht_range, hr, f, dB = dB)
