#  -------------- #
#  M O D U L E S  #
#  -------------- #

include("../../Utilities/MakieGL/MakieGL.jl")

# ----------------- #
#  E Q U A T I O N  #
# ----------------- #

# Piecewise DDFC function.
function generateDeWitte(fs::Number, B::Number, ceiling::Number, T::Number, nSamples::Number, 𝒳::Number, τ::Number;
                        plot::Bool = false, axis = false, label = "", figure, color = :blue, title = "De Witte NFLM")

    # --------------------- #
    #  P A R A M E T E R S  #
    # --------------------- #

    # Baseband chirp rate.
    M = B / T

    # ------------------- #
    #  F U N C T I O N S  #
    # ------------------- #

    # ζ
    ζ = ceiling - B/2 + τ
    # δ
    δ = 𝒳/τ - 𝒳/ζ
    # t̃
    t̃ = T/2 - δ

    # --------------------------- #
    #  W A V E F O R M   F R E Q  #
    # --------------------------- #

    # Time.
    #time = range(0, T, step = inv(fs))
    samples = 1:1:trunc(Int, ((nSamples-1)/2))

    # The modulation data.
    freq = Array{Float32}(undef, nSamples)

    # Freq at time 0.
    centerSample = ceil(Int, nSamples/2)
    freq[centerSample] = 0

    # Populate freq array.
    for s in samples

        # Time value
        t = s / fs

         # For |t| < t̃
        if abs(t) < t̃

            freq[centerSample + s] =   M * t
            freq[centerSample - s] = - M * t

        # For t̃ ⪬ |t| ⪬  T/2
        elseif t̃ <= abs(t) && abs(t) <= T/2

            den = -abs(t) + (T/2) + (𝒳/ζ)
            freq[centerSample + s] =   (M*t) + ( (𝒳/den) - τ )
            freq[centerSample - s] = - (M*t) - ( (𝒳/den) - τ )

        # Wave should not exist at this point.
        else

            freq[centerSample + s] = 0
            freq[centerSample - s] = 0

        end

    end

    println(maximum(freq))

    # ----------------- #
    #  P L O T T I N G  #
    # ----------------- #

    if plot
        
        if axis == false
            
            timeVec = (0:1:nSamples-1) / fs
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            scatterlines!(timeVec * 1e6, freq/1e6, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
            plotOrigin(ax)
            
        else
            
            ax = axis

        end
        
    else
        ax = nothing
    end 

    offset = (nSamples-1)/2
    n = (-offset:1:offset)
    fw = freq ./ fs
    return exp.(im * 2π .* fw .* n), ax

end

# ------- #
#  E O F  #
# ------- #

