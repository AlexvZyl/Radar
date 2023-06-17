#  -------------- #
#  M O D U L E S  #
#  -------------- #

include("../../../Utilities/MakieGL/MakieGL.jl")
include("../../../Utilities/MakieGL/PlotUtilities.jl")

using Peaks
using Optim # Remember to cite this package.

# ----------------- #
#  E Q U A T I O N  #
# ----------------- #

# Piecewise DDFC function.
function DDFCfreq(fs::Number, T::Number, τ::Number,
                  𝒳::Number, BWtot::Number, BWbase::Number)

    # Amount of samples in the waveform.
    nSamples = ceil(Int, T * fs)
    #  Ensure waveform is even.
    if nSamples % 2 == 0
        nSamples += 1
        T += inv(fs)
    end

    # --------------------- #
    #  P A R A M E T E R S  #
    # --------------------- #

    # Maximum instantaneous frequency.
    ceiling = BWtotal / 2
    # Baseband chirp rate.
    M = BWbase / T
    # ζ
    ζ = ceiling - BWbase/2 + τ
    # δ
    δ = 𝒳/τ - 𝒳/ζ
    # t̃
    t̃ = T/2 - δ

    # ------------------- #
    #  F R E Q U E N C Y  #
    # ------------------- #

    # Generate a samples array.
    samples = trunc.(Int, range(1, (nSamples-1)/2))

    # The modulation data.
    freq = Array{Float32}(undef, nSamples)
    time = Array{Float32}(undef, nSamples)

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

    # --------- #
    #  T I M E  #
    # --------- #

    time[centerSample] = 0
    for i in range(1, trunc(Int, (nSamples-1)/2))
        t = i / fs
        time[centerSample + i] =   t
        time[centerSample - i] = - t
    end

    return freq, time

end

# -------------------- #
#  P A R A ME T E R S  #
# -------------------- #

# Pulse length.
T = 200e-6

# Bandwidth of the tx signal.
BWtotal = 28e6

# Sampling the signal.
timeRes = 5e-9
fs = inv(timeRes)
# fs = BWtotal * 4

# ------------- #
#  T U N I N G  #
# ------------- #

# Baseband bandwidth added as tuning parameter.
TB = 270
BWbase = TB / T

# Tuning parameters suggested by the paper.
τ = 0.15     # Close in SLL
𝒳 = 1.7      # Far out SLL

# ----------------- #
#  P L O T T I N G  #
# ----------------- #

# Get the frequency over time.
freq, timeVec = DDFCfreq(fs, T, τ, 𝒳, BWtotal, BWbase)

# Signal.
nSamples = ceil(Int, T * fs)
# Ensure signal is even.
if nSamples % 2 == 0
    nSamples += 1
    T += inv(fs)
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
lines!(timeVec * 1e6, freq / 1e6, color = :blue, linewidth = lineThickness, label = "Frequency")
plotMatchedFilter(figure, signalDDFC, [1,2], fs, xRange = 400, yRange = 120)
plotSignal(figure, signalDDFC, [1,3], fs)
display(figure)

# This has to be below BW, otherwise this is an invalid waveform.
actualBandwidth = maximum(freq) * 2

# ------- #
#  E O F  #
# ------- #