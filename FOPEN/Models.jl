dB(x) = 20 * log10(x)

function Weissberger(f::Number, d::Number)
    if d <= 14
        return -dB(0.45 * f^0.284 * d)
    else
        return -dB(1.33 * f^0.284 * d^0.588)
    end
end

function FITUR_in_leaf(f::Number, d::Number)
    -dB(15.6 * f^(-0.009) * d^0.26)
end

function FITUR_out_of_leaf(f::Number, d::Number)
    -dB(26.6 * f^(-0.2) * d^0.5)
end

mutable struct Model
    func
    line_style
    marker
    string
end

function get_models()
    return [
        Model(Weissberger, :solid, :circle, "Weissberger"),
        Model(FITUR_out_of_leaf, :solid, :cross, "FITUR (out-of-leaf)"),
        Model(FITUR_in_leaf, :solid, :diamond, "FITUR (in-leaf)")
    ]
end

function attenuation(model::Model, distance, freq)
    return model.func.(freq, distance) 
end

function legend(model::Model, points)
    marker_point = Point2f((points[1][1] + points[2][1]) / 2, points[1][2])
    return [ LineElement(color=:black, linewidth=5, linestyle=model.line_style, linepoints=points), MarkerElement(color=:black, marker=model.marker, markersize=dotSize*5, points = [ marker_point ]) ]
end
