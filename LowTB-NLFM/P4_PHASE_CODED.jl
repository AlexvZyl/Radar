
function p4PhaseCode(M)

    m = 1:1:M
    return (π./M) .* (m .- 1).^2 .- (π .* (m .- 1))

end

function generateP4Code(fs::Number, BW::Number, nSamples::Number;
                    plot::Bool = false, axis = false, label = "P4 Code", figure, color = :blue, title = "P4 Phase Code")


    PHASE = p4PhaseCode(nSamples)
    t = (0:1:nSamples-1) / fs

    # Plot the generated phase.
   if plot
      
    if axis == false
       
       ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Phase (Radians)", title = title)
       scatterlines!(t * 1e6, PHASE, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
       plotOrigin(ax)
       axis = ax   
       
    else 
       
       scatterlines!(t, PHASE, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
       plotOrigin(axis)
       
    end
    
 end

    return exp.(2π * im * PHASE * BW), axis

end