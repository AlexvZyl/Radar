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
