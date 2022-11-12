include("../MakieGL/PlotUtilities.jl")

# Calculate (and plot) the signal's samples on the unit circle.
function PlotIQCircle(figure, signal::Vector, position;
                      axis = false, title = "I vs Q", color = :blue, label = "Signal")

    # Setup axis.
    ax = nothing
    if axis == false
        ax = Axis(figure[position[1], position[2]], xlabel = "I", ylabel = "Q", title = title)
    else
        ax = axis
    end

    # Plot.
    # scatterlines!(real.(signal), imag.(signal), color = color, markersize = dotSize, linewidth = lineThickness, label = label)
    scatter!(real.(signal), imag.(signal), color = color, markersize = dotSize * 2, linewidth = lineThickness, label = label)

    # Return the data.
    return ax

end
