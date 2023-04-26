include("../Utilities/MakieGL/MakieGL.jl")
include("Models.jl")

function get_colors()
    return [ :blue, :red, :orange, :purple, :cyan, :teal, :yellow ]
end

function generate_fopen_figures(range::Number, resolution::Number, freq)
    # Get results.
    models = get_models()
    d = resolution:resolution:range
    results = [ [ attenuation(m, d, f) for f in freq ] for m in models ]
     
    # Setup figure.
    fig = Figure(resolution = (2560,1440))
    ax = Axis(fig[1,1], xlabel="Foliage Thickness (m)", ylabel="Attenuation (dB)", title="Foliage Signal Attenuation")
    vlines!([0], color=:black, linewidth=3)
    hlines!([0], color=:black, linewidth=3)

    # Setup legend grid.
    legend_grid = GridLayout()
    legend_grid[1:2,1] = [ Axis(fig; leftspinevisible=false, rightspinevisible=false, topspinevisible=false, bottomspinevisible=false, xgridvisible=false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, xticksvisible=false, yticksvisible=false) for _ in 1:2 ]
    fig.layout[1,2] = legend_grid

    # Plot results.
    colors = get_colors()
    for (m,model) in enumerate(models)
        for (i,_) in enumerate(freq)
            scatterlines!(ax, d, results[m][i], markersize=dotSize*4, linewidth=2, marker=model.marker, color=colors[i], linestyle=model.line_style)
        end
    end

    # Manually create legend.
    points = [ Point2f(-2, 0.5), Point2f(1, 0.5) ]
    # Frequencies.
    Legend(
        legend_grid[1,1],
        [ LineElement(color=colors[i], linewidth=8, linepoints=points) for (i,_) in enumerate(freq) ],
        [ string("  ", f/1e9) for f in freq ],
        "Frequencies (GHz)",
        valign = :bottom,
        labelfont = "Latin Modern Math",
        titlefont = "Latin Modern Math",
        padding = 30,
        labelsize=45,
        titlesize=50
    )
    # Models.
    Legend(
        legend_grid[2,1],
        [ legend(m, points) for m in models ],
        [ string(model.string) for model in models ],
        "Models",
        valign = :top,
        labelfont = "Latin Modern Math",
        titlefont = "Latin Modern Math", 
        padding = (50,30,30,30),
        labelsize=45,
        titlesize=50
    )

    # Format and save.
    xlims!(d[1]-5, d[end]+5)
    save("FOPEN_Models.pdf", fig)
end

# Run script.
freq = [800e6, 1.2e9, 5e9, 10e9, 20e9, 50e9]
distance = 100
resolution = 5
generate_fopen_figures(distance, resolution, freq)
