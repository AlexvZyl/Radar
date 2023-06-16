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
                            plot::Bool = false, figure = false, axis = false, label = "",
                            title = "Leśnik NLFM Frequencies", color = :blue)

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
         
        timeVec2 = (0:1:(nSamples-1)) / fs
         scatterlines!(timeVec2 * 1e6, freqVec/1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
         # scatterlines!(timeVec2 * 1e6, PHASE, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
         
      end
      
   end

   # Return the waveform.
   return exp.(im * 2π * PHASE * Δ), axis
   
end


function lesnikSLLvsTBP(fs::Real, tiRange::Vector, bwRange::Vector, tbSamples::Real, lobeCount::Real;
                        figure = false, plot::Bool = false, axis = false, label = "Leśnik", title = "Leśnik SLL over TBP",
                        color = :blue, parameter::Real = 2e6)

       # Prepare data.
       SLLvector = Array{Float32}(undef, tbSamples)
       TBPvector = Array{Float32}(undef, tbSamples)
       tiIncrements = (tiRange[2] - tiRange[1]) / tbSamples
       bwIncrements = (bwRange[2] - bwRange[1]) / tbSamples
       tiVector = tiRange[1]:tiIncrements:tiRange[2]
       bwVector = bwRange[1]:bwIncrements:bwRange[2]
   
       # Create vector.
       for i in 1:1:(tbSamples)
           nSamples = floor(Int, tiVector[i] * fs)
           signal, null = generateLesnikNLFM(bwVector[i], fs, nSamples, tiVector[i], plot = false)
           mf = plotMatchedFilter(0, signal, [], fs, plot = false)
           SLLvector[i] = calculateSideLobeLevel(mf, lobeCount)
           TBPvector[i] = bwVector[i] * tiVector[i] 
       end
   
       # Plotting.
       if plot
           if axis == false
               ax = Axis(figure[1, 1], xlabel = "TBP (Hz * s)", ylabel = "SLL (dB)", title = title)
               scatterlines!(TBPvector, SLLvector, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
               plotOrigin(ax)
               tbpInc = bwIncrements * tiIncrements
               xlims!(TBPvector[1] - tbpInc, TBPvector[tbSamples] + tbpInc)
           else
               ax = axis
           end
       else
           ax = nothing
       end 
   
       # Done.
       return TBPvector, SLLvector, ax

end

function lesnikPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount;
                     axis = false, title = "Leśnik Plane", plot = true, figure = false)

   # Parameter vector.
   parameterIncrements = ( parameterRange[2] - parameterRange[1] ) / (parameterSamples-1)
   parameterVector = collect(parameterRange[1]:parameterIncrements:parameterRange[2])

   # Generate matrix.
   TBPvector = Array{Float32}(undef, tbSamples)
   sigmoidSLLTBPMatrix = Array{Float32}(undef, 0)
   for pScale in parameterVector
      TBPvector, SLLVector, ax = lesnikSLLvsTBP(fs, tiRange, bwRange, tbSamples, lobeCount, plot = false)
      append!(sigmoidSLLTBPMatrix, SLLVector)
   end
   sigmoidSLLTBPMatrix = reshape(sigmoidSLLTBPMatrix, (tbSamples, parameterSamples))

   # Axis.
   if axis == false
      ax = Axis3(figure[1, 1], xlabel = "TBP (Hz * s)", ylabel = "Parameter",zlabel = "SLL (dB)", title = title)
   else
      ax = axis
   end
   # Plot.
   if plot
      surface!(TBPvector, parameterVector, sigmoidSLLTBPMatrix)
      xlims!(TBPvector[1], TBPvector[tbSamples])
   end
   # Done.
   return sigmoidSLLTBPMatrix, TBPvector, ax

end
 
# ======= # 
#  E O F  #
# ======= #
