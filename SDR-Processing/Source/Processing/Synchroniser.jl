# --------------------------- #
#  S Y N C   F U N C T I O N  #
# --------------------------- #

function syncPulseCompressedSignal(signal::Vector, pulseLengthSamples::Number, syncRange::Vector)

    # First we have to find the first peak to sync the tx & receive signal.
    toSearch = abs.(signal[syncRange[1]:1:syncRange[2]])
    peakIndex = argmax(toSearch)
    syncedSignal = signal[peakIndex:1:end]

    # This might fix some weird things in the doppler map.
    # The last pulse is not going to be a full pulse, so it has to be removed.
    # How many pulses fit into the signal?
    totalPulses = floor(Int32, length(syncedSignal)/pulseLengthSamples)
    syncedSignal = syncedSignal[1:1:totalPulses*pulseLengthSamples]

end

# ------- #
#  E O F  #
# ------- #
