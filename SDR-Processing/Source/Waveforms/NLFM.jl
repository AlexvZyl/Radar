# 'Δ' desribes the side lobes level.
# Higher value = smaller sidelobes.
# Higher sidelobes lead to broader main lobe.


# 'B' Describes the main lobe width.
# Not used in the phase equation, but shows what
# happens to the main lobe.
# B = ( 2Δ * sqrt( Δ^2 + 4 ) ) / ( Δ^2 + 4 )

# Freq, given the time.
function fᵢ(t, tᵢ, Δ)
   α = t - ( tᵢ/2 )
   β = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   γ = ( t - tᵢ/2 ) ^ 2
   return α / sqrt(β - γ)
end

# Phase, given the time.
function Φ(t, tᵢ, Δ)
   α = ( tᵢ * sqrt(Δ^2 + 4) ) / ( 2 * Δ )
   β = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   γ = ( t - tᵢ/2 ) ^ 2
   return α - sqrt(β - γ)
end
