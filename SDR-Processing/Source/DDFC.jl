#  -------------- #
#  M O D U L E S  #
#  -------------- #

include("../../Utilities/MakieGL.jl")
include("Utilities.jl")

using Peaks

# ----------------- #
#  E Q U A T I O N  #
# ----------------- #

# Piecewise DDFC function.
function DDFCfreq(fs::Number, ceiling::Number, M::Number;
                  τ::Number, 𝒳::Number, B::Number)

    # --------------------- #
    #  P A R A M E T E R S  #
    # --------------------- #

    # M = baseband chirp rate.
    M = B / T

    # ζ
    ζ = ceiling - B/2 + τ
    # δ
    δ = 𝒳/τ - 𝒳/ζ
    # t̃
    t̃ = T/2 - δ

    # ----------------- #
    #  W A V E F O R M  #
    # ----------------- #

    # Amount of samples in the waveform.
    nSamples = ceil(Int, T * fs)
    if nSamples % 2 == 0
        nSamples += 1
    end
    # Generate a time vector.
    samples = range(1, (nSamples-1)/2)

    # The arrays.
    freq = Array{Float32}(undef, nSamples)
    time = Array{Float32}(undef, nSamples)

    # ------------------- #
    #  F R E Q U E N C Y  #
    # ------------------- #

    # Freq at time 0.
    centerSample = ceil(Int, nSamples/2)
    freq[centerSample] = 0

    for s in samples

        # Cast to int.
        s = trunc(Int, s)

        # Time value
        t = s / fs

         # For |t| < t̃
        if abs(t) < t̃

            freq[centerSample + s] =   M * t
            freq[centerSample - s] = - M * t

        # For t̃ ⪬ |t| ⪬  T/2
        elseif t̃ <= abs(t) && abs(t) <= T/2

            den = -abs(t) + (T/2) + (𝒳/ζ)
            freq[centerSample + s] = (M*t) + ( (𝒳/den) - τ )
            freq[centerSample - s] = (M*t) - ( (𝒳/den) - τ )

        # Wave should not exist at this point (I think).
        else

            freq[centerSample + s] = 0
            freq[centerSample - s] = 0

        end

    end

    # --------- #
    #  T I M E  #
    # --------- #

    time[centerSample] = 0
    for i in range(1, trunc(Int, (nSamples-1)/2))
        t = i /fs
        time[centerSample + i] = t
        time[centerSample - i] = -t
    end

    return freq, time

end

# -------------------- #
#  P A R A ME T E R S  #
# -------------------- #

fs = 200e6            # Sampling frequency.
BW = fs / 2.1        # Bandiwdth.
T = 0.333e-6 # μs.   # Pulse length.
T = 200e-6 # μs.   # Pulse length.

# ceiling = This is the max freq we can transmit.
#           It has to be set to the BW.
ceiling = BW # Hz.

# ------------- #
#  T U N I N G  #
# ------------- #

# Has to be designd using the paper.
# Going to implement my own optimiser.
τ = 0.1     # Close in SLL
𝒳 = 1.17    # Far out SLL

# B = This is the baseband bandiwdth, but we add a non-linear
# part to the end of the waveform.  In the paper they restrict it
# to a value that is a little broader than BW/2.
# What they do in the paper does not make sense, so I am going to
# see this as a tuning parameter.
B = BW / 4 # Hz.

# ----------------- #
#  P L O T T I N G  #
# ----------------- #

# Get the frequency over time.
freq, timeVec = DDFCfreq(fs, T, ceiling, τ=τ, 𝒳=𝒳, B=B)

# Signal.
nSamples = ceil(Int, T * fs)
if nSamples % 2 == 0
    nSamples += 1
end
signalDDFC = Array{Complex{Float32}}(undef, nSamples)
for i in range(1, nSamples)
    signalDDFC[i] = exp(im * 2 * pi * freq[i])
end

# Plot.
figure = Figure()
axis = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "DDFC Modulation",
       titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
plotOrigin(axis)
lines!(timeVec, freq, color = :blue, linewidth = lineThickness, label = "Frequency")
plotMatchedFilter(figure, signalDDFC, [1,2], fs)
display(figure)

# This has to be below BW, otherwise this is an invalid waveform.
actualBandwidth = maximum(freq)

# ------- #
#  E O F  #
# ------- #
