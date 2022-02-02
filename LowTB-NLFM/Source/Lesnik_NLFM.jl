# The NLFM waveform presented in the paper by C. Lesnik.
# It improved upon the NLFm waveform presented in the paper
# by De Witte and Griffiths.

# ================= #
#  W A V E F R O M  #
# ================= #

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
   α / sqrt(β - γ)
end

# Phase, given the time.
function Φ(t, tᵢ, Δ)
   α = ( tᵢ * sqrt(Δ^2 + 4) ) / ( 2 * Δ )
   β = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   γ = ( t - tᵢ/2 ) ^ 2
   α - sqrt(β - γ)
end

# Generate the NLFM waveform.
function generateNLFM(BW::Number, fs::Number, nSamples::Number)

   # Calculate the phases.
   tᵢ = nSamples / fs
   timeVec = ( 0:1:(nSamples-1) ) / fs
   PHASE = Φ.(timeVec, tᵢ, BW)
   # Generate the wave.
   wave = exp.(2 * pi * im * BW * PHASE)
   return wave

end

# ======= # 
#  E O F  #
# ======= #