# ============================================================ #
# Packages.                                                    #
# ============================================================ #

using GLMakie
using FFTW

# ============================================================ #
# FFT.                                                         #
# ============================================================ #

# Takes the 2 channels and computes the FFT.
# The absolute value is returned.
# The draw boolean sets if it is drawn in Makie.
function complexFFT(fs, I, Q; draw::Bool=false)

    # Calculate the FFT.
    v_FFT = abs.(fft(I + Q*im))

    # Draw the FFT.
    if(draw)
        f2 = Figure()
        Axis(f2[1, 1], xlabel = "Sample", ylabel = "Magnitude", title = "FFT")
        scatter!(v_FFT)
        display(f2)
    end # If.

    return v_FFT
end # Function.

# ============================================================ #
# Calculate the Doppler FFT.                                   #
# ============================================================ #

# Takes the file data, aligns the pulses and calculates the
# Doppler fft.
function dopplerFFT()

end # Function.

# ============================================================ #
# EOF.                                                         #
# ============================================================ #
