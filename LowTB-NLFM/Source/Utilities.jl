using Peaks
using Statistics

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