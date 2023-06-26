include("Multipath.jl")

# Scene parameters.
hr = 3
R = 75
f_range = 900e6:100e6:1.1e9
f = 1.1e9
dB = true

# MP Effect Bigger picture.
height_target = 1
R_range = 10:5:1000
hr_range = 0:0.1:10
file_name = "MP_HEATMAP_BIG.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
save(file_name, figure)

# MP Effect Target 0m.
height_target = 0.1
R_range = 10:1:100
hr_range = 0:0.01:3
file_name = "MP_HEATMAP_TARGET_0.1m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
save(file_name, figure)

# MP Effect Target 0.5m.
height_target = 0.5
R_range = 10:1:100
hr_range = 0:0.01:3
file_name = "MP_HEATMAP_TARGET_0.5m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
save(file_name, figure)

# MP Effect Target 1m.
height_target = 1
R_range = 10:1:100
hr_range = 0:0.01:3
file_name = "MP_HEATMAP_TARGET_1m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
save(file_name, figure)

# MP Effect Target 2m.
height_target = 2
R_range = 10:1:100
hr_range = 0:0.01:3
file_name = "MP_HEATMAP_TARGET_2m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_radar(R_range, hr_range, height_target, f, dB = dB)
save(file_name, figure)

# MP Effect Radar 1m.
hr = 1
R_range = 10:1:100
ht_range = 0:0.01:2
file_name = "MP_HEATMAP_RADAR_1m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_target(R_range, ht_range, hr, f, dB = dB)
save(file_name, figure)

# MP Effect Radar 3m.
hr = 3
R_range = 10:1:100
ht_range = 0:0.01:2
file_name = "MP_HEATMAP_RADAR_3m.pdf"
figure = plot_multipath_heatmap_flat_earth_vary_target(R_range, ht_range, hr, f, dB = dB)
save(file_name, figure)
