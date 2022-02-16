include("../../Utilities/MakieGL/MakieGL.jl")

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

   α = t .- ( tᵢ/2 )
   β = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   γ = ( t .- tᵢ/2 ) .^ 2
   α ./ sqrt.(β .- γ)

end

# Phase, given the time.
function Φ(t, tᵢ, Δ)

   # α = ( tᵢ * sqrt(Δ^2 + 4) ) / ( 2 * Δ )
   # β = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   # γ = ( t .- tᵢ/2 ) .^ 2
   # α .- sqrt.(β .- γ)

   α = tᵢ * sqrt(Δ^2 + 4)/(2 * Δ)
	(α - sqrt(α^2 - (t - tᵢ/2)^2))/Δ

end

# function ωₜ(t, tᵢ, Δ)

#    # Constants used to make writing the equation easier.
#    C2 = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 )
#    C3 = tᵢ / 2

#    # ωₙ is calculated by taking the integral of the phase.
#    # This was calculated by hand and is now implemented here.
#    T1 = ( C2 .- ( t .- C3 ) .^2 ) .^ (-0.5)
#    T2 = ( t .- C3 )
#    T1 .* T2

# end

# function fₜ(t, tᵢ, Δ)

#    # Constants.
#    C1 = tᵢ / 2
#    C2 = ( tᵢ^2 * (Δ^2+4) ) / ( 4*Δ^2 ) 

#    # Terms.
#    T1 = t .* ( C2 .- (t.-C1).^2 ) .^ (-0.5)
#    T2 = ( t .- C1 ) .^ 2
#    T3 = ( C2 .- (t.-C1).^2 ) .^ (-1.5)

#    # Frequency.
#    T1 .- T2 .* T3

# end

# Generate the NLFM waveform.
function generateLesnikNLFM(Δ::Number, fs::Number, nSamples::Number, tᵢ::Number; 
                            plot::Bool = false, figure::Figure)

   # ----------- #
   #  P H A S E  #
   # ----------- #

   # Calculate the phase.
   # tᵢ += inv(fs)
   timeVec = (1:1:nSamples-1) / fs
   freqVec = fᵢ.(timeVec, tᵢ, Δ)

   # Plot the generated phase.
   if plot
      ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "Lesnik NLFM Frequencies")
      lines!(timeVec * 1e6, freqVec/1e6, linewidth = lineThickness, color = :blue)
      plotOrigin(ax)
   end

   # ----------------- #
   #  W A V E F O R M  #
   # ----------------- #
   
   # l = floor(Int, nSamples/2)
   # samplesVec = -l:1:l
   # samplesVec = 0:1:nSamples-1
   # return exp.(im * samplesVec .* wₙ)
   # return exp.(2 * pi * im * samplesVec .* freqI ./ fs)
   # return exp.(im * 2π * phase * BW)

end

# ======= # 
#  E O F  #
# ======= #