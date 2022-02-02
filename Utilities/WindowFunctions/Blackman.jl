# ============ #
#  W I N D O W #
# ============ #

function blackmanWindow(signal::Vector)

    # Apply the blackman window.
    nSamples = length(signal)
    samples = collect(0:1:nSamples-1)
    blackman(n, N) = 0.42 - 0.5 * cos((2 * pi * n) / (N - 1)) + 0.08 * cos(((4 * pi * n) / (N - 1)));
    signal .*= blackman.(samples, nSamples) 

end

# ======= #
#  E O F  #
# ======= #