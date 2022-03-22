using Peaks
using Statistics

function calculateSideLobeLevel(signal::Vector, lobeCount::Real)

    SLLarray = Array{Float32}(undef, lobeCount)
    indexMax = argmax(signal)
    currIndex = indexMax
    for i in 1:1:lobeCount
        currIndex = findnextmaxima(signal, currIndex + 1)
        if currIndex > length(signal)
            SLLarray = SLLarray[1:(i-1)]
            break
        end
        SLLarray[i] = signal[currIndex]
    end

    # Return the SLL.
    return -1 * (signal[indexMax] - mean(SLLarray))

end