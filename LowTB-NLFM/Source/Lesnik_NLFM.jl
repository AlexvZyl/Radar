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
   γ = α .^ 2
   α ./ sqrt.(β .- γ)

end

# Phase, given the time.
function Φ(t, tᵢ, Δ)

   α = tᵢ * sqrt(Δ^2 + 4)/(2 * Δ)
	(α - sqrt(α^2 - (t - tᵢ/2)^2))/Δ

end

# Generate the NLFM waveform.
function generateLesnikNLFM(Δ::Number, fs::Number, nSamples::Number, tᵢ::Number; 
                            plot::Bool = false, figure::Figure, axis = false, label = "",
                            title = "Leśnik NLFM Frequencies")

   # ----------- #
   #  P H A S E  #
   # ----------- #

   # Calculate the phase.
   tᵢ -=  inv(fs)
   Δ /= 1e6  # They used normalised frequencies?...
   timeVec = (0:1:nSamples-1) / fs
   freqVec = fᵢ.(timeVec, tᵢ, Δ) .* 1e6

   t = range(0, tᵢ, step = inv(fs))
   PHASE = Φ.(t, tᵢ, Δ)

   Δ *= 1e6

   # Waveform.
   offset = (nSamples-1) / 2
   n = (-offset:1:offset)
   t = n ./ fs     
      
   # Plot the generated phase.
   if plot
      
      if axis == false
         
         ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
         # scatterlines!(timeVec * 1e6, freqVec / 1e6, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
         scatterlines!(n, freqVec .* t, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
         scatterlines!(n, PHASE * Δ, linewidth = lineThickness, color = :orange, markersize = dotSize, label = label)
         plotOrigin(ax)
         axis = ax   
         
      else 
         
         timeVec2 = (0:1:nSamples) / fs
         scatterlines!(timeVec2 * 1e6, freqVec/1e6, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
         # scatterlines!(timeVec2 * 1e6, PHASE, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
         plotOrigin(axis)
         
      end
      
   end

   return exp.(im * 2π * PHASE * Δ), axis
   
end
 
# ======= # 
#  E O F  #
# ======= #