include("../../Utilities/MakieGL.jl")
include("Utilities.jl")


# ----------------- #
#  E Q U A T I O N  #
# ----------------- #

# Piecewise DDFC function.
function DDFCfreq(fs::Number, ceiling::Number, M::Number)

    # ------------- #
    #  T U N I N G  #
    # ------------- #

    # HAve to be cal
    τ = 1
    𝒳 = 1 # Δf × δ7

    # B = This is the baseband bandiwdth, but we add a non-linear
    # part to the end of the waveform.  In the paper they restrict it
    # to a value that is a little broader than BW/2.
    # What they do in the paper does not make sense, so I am going to
    # see this as a tuning parameter.
    B = BW / 4 # Hz.

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

    # The mdulated waveform.
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

        # Wave should not exist at this point.
        else

            freq[centerSample + s] = 0
            freq[centerSample - s] = 0

        end

    end

    # --------- #
    #  T I M E  #
    # --------- #

    timeRange = (nSamples-1)/2 /fs
    timeVec = range(-timeRange, timeRange, step = inv(fs))

    return freq, timeVec

end

# -------------- #
#  T E S T I N G #
# -------------- #

fs = 100e6              # Sampling frequency.
BW = fs / 2.1           # Bandiwdth.
T = 3.333333e-6 # μs.   # Pulse length.
# ceiling = This is the max freq we can transmit.
#           It has to be set to the BW.
ceiling = BW # Hz.

# Get the frequency over time.
freq, timeVec = DDFCfreq(fs, T, ceiling)
freq /= 10e6
timeVec *= 10e6

fig = Figure()
axis = Axis(fig[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = "DDFC Modulation",
     titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
plotOrigin(axis)
lines!(timeVec, freq, color = :blue, linewidth = lineThickness, label = "Frequency")
display(fig)

# ------- #
#  E O F  #
# ------- #
