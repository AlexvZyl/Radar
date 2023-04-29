using CSV
using DataFrames

include("../Utilities/MakieGL/MakieGL.jl")

data = CSV.read("Data/S11_LPDA.csv", DataFrame)[7:end-1, 1:3]
freq = parse.(Float64,  data[:,1]) ./ 1e9
s11 = parse.(Float64,  data[:,2])

opt_index = 60
opt_freq = parse(Float32, data[opt_index,1]) / 1e9
opt_s11 = parse(Float32, data[opt_index, :][2])

figure = Figure(resolution=(1920,1080))
ax = Axis(figure[1,1], xlabel = "Frequency (GHz)", ylabel = "Magnitude (dB)", title = "LP0965 Reflection Coefficient (S11)")
scatterlines!(freq, s11, markersize=11)
xlims!(0.8, 2)
ylims!(-40, 0)

lines!([opt_freq, opt_freq], [-40, opt_s11], color = :black, linewidth=3, linestyle=:dash)
lines!([0, opt_freq], [opt_s11, opt_s11], color = :black, linewidth=3, linestyle=:dash)
text!(opt_freq, -40, text = " 1.101", fontsize = 45)
text!(0.8, opt_s11, text = " -29.42", fontsize = 45)

save("Antenna_S11.pdf", figure)
