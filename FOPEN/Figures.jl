include("../Utilities/MakieGL/MakieGL.jl")
include("Models.jl")

function get_model_string(model::Function)
    if model == Weissberger
        return "Weissberger"
    elseif model == FITUR_in_leaf
        return "FITURE (in-leaf)"
    elseif model == FITUR_out_of_leaf
        return "FITURE (out-of-leaf)"
    end
end

function generate_fopen_figure(model::Function, range::Number, resolution::Number, freq)
    d = resolution:resolution:range
    attenuation = [ model.(f, d) for f in freq ]
    fig = Figure(resolution = (1920,1080))
    ax = Axis(fig[1,1], xlabel="Distance (m)", ylabel="Signal Power (dB)", title="$(get_model_string(model)) FOPEN Attenuation")
    for (i,a) in enumerate(attenuation)
        scatterlines!(d, a, linewidth=lineThickness, markersize=dotSize, label="$(freq[i]) Hz")
    end
    xlims!(-5, range+5)
    axislegend(ax)
    file = get_model_string(model) * "_Models.pdf"
    save(file, fig)
end

freq = [800e6, 1.2e9, 5e9, 10e9, 20e9, 50e9]
distance = 100
resoltion = 0.5
generate_fopen_figure(Weissberger, distance, resoltion, freq)
generate_fopen_figure(FITUR_in_leaf, distance, resoltion, freq)
generate_fopen_figure(FITUR_out_of_leaf, distance, resoltion, freq)
