using CSV
using DataFrames
using Plots

#=
plotly()

# Theme.
default(
    fontfamily = "Computer Modern",
    titlefontsize = 15,
    size = (1000,1000),
    legend = false,
    proj = :polar,
)

# Data.
data = CSV.read("Data/ASP.csv", DataFrame)
data = data[1810:1990,[3,4]]

# Plot.
p = plot(data[:,1] * π/180, data[:,2]
print(p)
title!("LP0965 Radiation Pattern (1.1 GHz)")
xlabel!("Angle (degrees)")
ylabel!("Gain (dB)")

savefig("LP0965_1.1GHz_Pattern.pdf")
=#

using Plotly

# Create some data for the plot
theta = range(0, stop=2π, length=100)
r = sin.(3*theta)

# Create the plot trace
trace = scatterpolar(r=r, theta=theta)

# Create the layout for the polar plot
layout = Layout(
    polar = (
        radialaxis = (
            visible = true,
            range = [0, 1]
        )
    )
)

# Create the plot object
plot([trace], layout_polar=layout)
