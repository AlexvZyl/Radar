using Peaks
using Statistics
using Interpolations

function calculateSideLobeLevel(signal::Vector)

    signalLength = length(signal)
    PSL = -Inf
    searchIndex = 0
    # Find the peak so that we do not count it as a PSL.
    peakIndex = argmax(signal)

    # Search for the largest peak.
    while true
        searchIndex  = findnextmaxima(signal, searchIndex + 1)
        # Do not compare to main lobe.
        if searchIndex == peakIndex
            continue
        elseif searchIndex > signalLength 
            break
        elseif signal[searchIndex] > PSL
            PSL = signal[searchIndex]
        end
    end

    # No peak found.
    if PSL == -Inf
        return 0
    # Return SLL.
    else 
        return -1 * (signal[peakIndex] - PSL)
    end
end

# Calculate the width of the main lobe at the given dB point.
# Currently using linear interpolations.
# Returns the width in samples
function calculateMainLobeWidth(signal::Vector; dB::Real = 0)

    # Find the max.
    maxIndex = argmax(signal)
    
    # Use minima point.
    if dB == 0

        # Positive halve minima.
        posMinima = findnextminima(signal, maxIndex+1)
        posLength = posMinima - maxIndex

        # Negative halve minima.
        signal = reverse(signal)
        maxIndex = argmax(signal)
        negMinima = findnextminima(signal, maxIndex+1)
        negLength = negMinima - maxIndex
        
        # Return the two added.
        return posLength + negLength

    # Calculate at dB point.
    else

        # Search to the dB point.
        dbIndex = maxIndex
        while(signal[dbIndex] > dB)
            dbIndex+=1
        end
        totalSamples = dbIndex - maxIndex
        samples = 0:1:(totalSamples)
        dbValues = -1 * signal[maxIndex:1:dbIndex]
        interpolate = LinearInterpolation(Interpolations.deduplicate_knots!(dbValues, move_knots = true), samples)
        return (interpolate(-1*dB) * 2)

    end
end