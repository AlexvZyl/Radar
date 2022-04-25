#  -------------- #
#  M O D U L E S  #
#  -------------- #

include("../../Utilities/MakieGL/MakieGL.jl")
using QuadGK

# ------------------- #
#  F R E Q U E N C Y  #
# ------------------- #

function deWitteFi(sample::Real, M::Real, fs::Real, T::Real, 𝒳::Real, ζ::Real, t̃::Real)

    # Time value
    t = sample / fs

    # |t| < t̃
    if abs(t) < t̃

        return M * t

    # t̃ ⪬ |t| ⪬  T/2
    elseif t̃ <= abs(t) && abs(t) <= T/2

        den = -abs(t) + (T/2) + (𝒳/ζ)
        return (M*t) + ( (𝒳/den) - τ ) * (t / abs(t))  # This is to get the sign.

    end

    # Wave should not exist at this point.
    return 0

end

# ----------- #
#  P H A S E  #
# ----------- #

function deWittePhaseSection1(sample::Real, M::Real, fs::Real, T::Real, 𝒳::Real, ζ::Real, startTime::Real)

    # Time value
    t = sample / fs
    # Return the integral.
    phase, err = quadgk(x -> (M*x) + ( (𝒳/(-abs(x) + (T/2) + (𝒳/ζ))) - τ ) * (t / abs(t)), startTime, t, rtol=1e-3)
    return phase

end

function deWittePhaseSection2(sample::Real, M::Real, fs::Real, prevSectionEndTime::Real, prevSectionPhase::Real)
    
    # Time value
    t = sample / fs
    # Return the integral.
    phase, err = quadgk(x -> (M*x), prevSectionEndTime, t, rtol=1e-3)
    return phase + prevSectionPhase
    
end

function deWittePhaseSection3(sample::Real, M::Real, fs::Real, T::Real, 𝒳::Real, ζ::Real, prevSectionEndTime::Real, prevSectionPhase::Real)

    # Time value
    t = sample / fs
    # Return the integral.
    phase, err = quadgk(x -> (M*x) + ( (𝒳/(-abs(x) + (T/2) + (𝒳/ζ))) - τ ) * (t / abs(t)), prevSectionEndTime, t, rtol=1e-3)
    return phase + prevSectionPhase

end

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

    # ------------------------- #
    #  F R E Q   &   P H A S E  #
    # ------------------------- #

    # Samples.
    offset = (nSamples-1) / 2
    samples = -offset:1:offset
    # Phase array.
    phase = Array{Float32}(undef, nSamples)
    
    # De Witte Section 1.
    index = 1
    while(abs(samples[index]/fs) >= t̃)
        phase[index] = deWittePhaseSection1(samples[index], M, fs, T, 𝒳, ζ, -offset/fs)
        index+=1
    end
    endOfSection1 = index-1

    # De Witte section 2.
    while(abs(samples[index]/fs) < t̃)
        phase[index] = deWittePhaseSection2(samples[index], M, fs, samples[endOfSection1]/fs, phase[endOfSection1])
        index+=1
    end
    endOfSection2 = index-1

    # De Witte section 3.
    while(index <= nSamples)
        phase[index] = deWittePhaseSection3(samples[index], M, fs, T, 𝒳, ζ, samples[endOfSection2]/fs, phase[endOfSection2])
        index+=1
    end

    # ----------------- #
    #  P L O T T I N G  #
    # ----------------- #

    if plot
        
        if axis == false
            
            timeVec = (0:1:nSamples-1) / fs
            # ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            # scatterlines!(timeVec * 1e6, freq/1e6, linewidth = lineThickness, color = :blue, markersize = dotSize, label = label)
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Phase (radians)", title = title)
            scatterlines!(timeVec * 1e6, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
            
        else
            
            ax = axis

        end
        
    else
        ax = nothing
    end 

    return exp.(im * 2π * phase), ax

end

# ------------------- #
#  O P T I M I S E D  #
# ------------------- #

function generateOptimisedDeWitte()

    

end

# ------- #
#  E O F  #
# ------- #