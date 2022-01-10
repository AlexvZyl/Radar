# --------------------- #
#  P A R A M E T E R S  #
# --------------------- #

# We need to specify M, B, T and ceiling.
# T = Pulselength.
# ceiling = Upper bound for the instantanous freq.  Bandwidth?...
# M = Time * Bandwidth?...
# B =

# We need to calculate τ, 𝒳 via the paper's method.

# ζ
ζ = ceiling - B/2 + τ

# δ
δ = 𝒳/τ - 𝒳/ζ

# 𝓉
𝓉 = T/2 - δ

# ----------------- #
#  E Q U A T I O N  #
# ----------------- #

# Piecewise DDFC function.
function fᵢ(t)



     # For |t| < 𝓉
    if abs(t) < 𝓉

        M * t

    # For 𝓉 ⪬ |t| ⪬  T/2
    elseif 𝓉 <= abs(t) && abs(t) <= T/2

        den = -abs(t) + T/2 + 𝒳/ζ

        plus = M * t + ( 𝒳 / den - τ )
        minus = M * t - ( 𝒳 / den - τ )

    else

        return 0

    end

end

# ------- #
#  E O F  #
# ------- #
