include("../../Utilities/MakieGL/MakieGL.jl")
using QuadGK

function sigmoidFreq(x, fs::Real, BW::Real, scale::Real; onlyFreq::Bool = false)

    val = scale .*  (x .- 0.5)
    den = 1 .+ exp.( -val )
    sigmoidResult = ( 1 ./ den  ) 

    timeNorm = sigmoidResult
    timeNorm .-= minimum(timeNorm)
    timeNorm ./= maximum(timeNorm)
    time = timeNorm .* (nSamples-1)/fs

    freq = ( x .- 0.5 ) * BW

    if onlyFreq
        return freq
    end

    return time, freq 

end

function sigmoidPhase(x, fs::Real, BW::Real, scale::Real)

    return quadgk.(fx -> sigmoidFreq(fx, fs, BW, scale, onlyFreq = true) , 0, x, rtol = 1e-3)

end

logit(fx, scale) = log(ℯ,  fx / (1 - fx) ) / scale
sigmoid(fx, scale) = 1 / ( 1 + exp(-1 * scale *fx) )

function logitFreq(fs::Real, BW::Real, scale::Real, nSamples::Real; onlyFreq::Bool = false)

    range = sigmoid(BW/2, scale)
    beginTime = 0.5 - range/2
    endTime = 0.5 + range/2
    # Create the logit function.
    normTime = beginTime:1/(nSamples+1):endTime
    freq = logit.(normTime, scale)
    # Remove the Inf values.
    popfirst!(freq)
    pop!(freq)
    # Range the freq in BW.
    freq = freq ./ maximum(abs.(freq))
    freq .*= (BW / 2)
    time = collect(0:1:(nSamples-1)) / fs
 
    # Return.
    if onlyFreq
        return freq
    end
    return time, freq

end

function logitPhase(fs::Real, BW::Real, scale::Real, nSamples::Real; onlyFreq::Bool = false)

    # Create time vec.
    normTime = collect(0:1/(nSamples+1):1)
    popfirst!(normTime)
    pop!(normTime)

    # Generate phase.
    phase = Array{Float32}(undef, nSamples)
    index = 1
    for t in normTime
        phase[index], err = quadgk(x -> log(ℯ,  x / (1 - x) ), normTime[1], t, rtol = 1e-3)
        index+=1
    end

    # Scale the phase.
    phase ./= maximum(abs.(phase)*2)

    return phase

end

function generateSigmoidWaveform(fs::Number, BW::Number, nSamples::Real;
                                 plot::Bool = false, axis = false, label = "Sigmoid", figure, color = :blue, title = "Sigmoid NFLM")

    # time, freq = logitFreq(fs, BW, 1, nSamples)
    time = collect(0:1:(nSamples-1)) / fs
    phase = logitPhase(fs, BW, 1, nSamples)

    # ----------------- #
    #  P L O T T I N G  #
    # ----------------- #

    if plot
        
        if axis == false
            
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            # scatterlines!(time * 1e6, freq / 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            scatterlines!(time * 1e6, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
            
        else
            
            ax = axis

        end
        
    else
        ax = nothing
    end 

    return exp.(2π * phase * BW * im / 1e6), ax

end