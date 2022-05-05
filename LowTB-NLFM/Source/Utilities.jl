using Peaks
using Statistics
using Interpolations

function calculateSideLobeLevel(signal::Vector, lobeCount::Real)

    SLLarray = Array{Float32}(undef, lobeCount)
    indexMax = argmax(signal)
    currIndex = indexMax
    signalLength = length(signal)
    for i in 1:1:lobeCount
        currIndex = findnextmaxima(signal, currIndex + 1)
        if currIndex > signalLength
            SLLarray = SLLarray[1:(i-1)]
            break
        end
        SLLarray[i] = signal[currIndex]
    end

    if(length(SLLarray) > 0)
        return -1 * (signal[indexMax] - maximum(SLLarray))
    else 
        return 0
    end
end

# Calculate the width of the main lobe at the given dB point.
# Currently using linear interpolations.
# Returns the width in samples
function calculateMainLobeWidth(signal::Vector; dB::Real = 0)

    # Find the max.
    val, maxIndex = findmax(signal)
    
    # Use minima point.
    if dB == 0

        # Find the width to the first minima.
        minimaIndex = findnextminima(signal, maxIndex+1)
        return ((minimaIndex - maxIndex) * 2) + 1

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