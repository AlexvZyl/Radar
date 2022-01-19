# ----------- #
#  S E T U P  #
# ----------- #

include("../Utilities.jl")

# ----------------------- #
#  D O P P L E R   F F T  #
# ----------------------- #

function plotDopplerFFT(figure::Figure, signal::Vector{Complex{Float32}}, position::Vector
                        initialSamples::Number;
                        xRange::Number=Inf, yRange::Number = Inf)

    # First we have to find the first peak to sync the tx & receive signal.
    toSearch = signal[1:1:initialSamples]
    peakIndex = argmax(toSearch)



end

# ------- #
#  E O F  #
# ------- #
