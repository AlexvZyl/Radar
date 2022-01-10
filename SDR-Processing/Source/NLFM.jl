# Δ desribes the side lobes level.
# Higher value = smaller sidelobes.
# Higher sidelobes lead to broader main lobe.
Δ = 50e6
# Describes the main lobe width.
# Not used in the phase equation, but shows what
# happens to the main lobe.
B = ( 2Δ * sqrt( Δ^2 + 4 ) ) / ( Δ^2 + 4 )

# Phase, given the time.
function Φ(t, tᵢ)
   α = ( tᵢ * sqrt(Δ^2 + 4) ) / (2 * Δ)
   β = ( tᵢ^2 * ( Δ^2 + 4 ) ) / ( 4 * Δ^2 )
   γ = ( t - tᵢ/2 ) ^ 2
   α - sqrt(β - γ)
end
