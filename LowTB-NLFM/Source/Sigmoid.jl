include("../../Utilities/MakieGL/MakieGL.jl")
include("Utilities.jl")
using QuadGK

# function sigmoidFreq(x, fs::Real, BW::Real, scale::Real; onlyFreq::Bool = false)
#     val = scale .*  (x .- 0.5)
#     den = 1 .+ exp.( -val )
#     sigmoidResult = ( 1 ./ den  ) 
#     timeNorm = sigmoidResult
#     timeNorm .-= minimum(timeNorm)
#     timeNorm ./= maximum(timeNorm)
#     time = timeNorm .* (nSamples-1)/fs
#     freq = ( x .- 0.5 ) * BW
#     if onlyFreq
#         return freq
#     end
#     return time, freq 
# end

# function sigmoidPhase(x, fs::Real, BW::Real, scale::Real)
#     return quadgk.(fx -> sigmoidFreq(fx, fs, BW, scale, onlyFreq = true) , 0, x, rtol = 1e-3)
# end

logit(fx, scale) = log(ℯ,  fx / (1 - fx) ) / scale
sigmoid(fx, scale) = 1 / ( 1 + exp(-1 * scale *fx) )

function logitFreq(time, fs::Real, BW::Real, scale::Real, nSamples::Real; onlyFreq::Bool = false)

    # Calculate logit frequency.    
    freq = logit.(time, scale)

    # Range the freq in BW.
    freq = freq ./ maximum(abs.(freq))
    freq .*= (BW / 2)
 
    # Return.
    return freq

end

function logitPhase(time, fs::Real, BW::Real, scale::Real, nSamples::Real; onlyFreq::Bool = false)

    # Generate phase.
    phase = Array{Float32}(undef, nSamples)
    for i in 1:1:nSamples
        phase[i], err = quadgk(x -> log(ℯ,  x / (1 - x) ), time[1], time[i], rtol = 1e-3)
    end

    # Scale the phase.
    phase ./= maximum(abs.(phase)*2)
    return phase

end

function generateSigmoidWaveform(fs::Number, BW::Number, nSamples::Real;
                                 plot::Bool = false, axis = false, label = "Sigmoid", figure = false, color = :blue, title = "Sigmoid NFLM",
                                 scalingParameter::Real = 1)

    # Create time vector.
    startTime = 0.5 - scalingParameter * 0.5
    endTime = 0.5 + scalingParameter * 0.5
    increment = (endTime-startTime)/(nSamples+2)
    # Remove edge cases (they might be on 0 or 1)
    time = collect(startTime:increment:endTime)
    popfirst!(time)
    pop!(time)
    
    # Calculate vectors.
    freq = logitFreq(time, fs, BW, 1, nSamples)
    phase = logitPhase(time, fs, BW, 1, nSamples)

    # Plotting.
    if plot        
        if axis == false 
            time = (0:1:(nSamples))/fs
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            scatterlines!(time * 1e6, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            # scatterlines!(time * 1e6, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
        else
            ax = axis
        end
    else
        ax = nothing
    end 

    # Done.
    return exp.(2π * phase * BW * im / 1e6), ax

end

function sigmoidSLLvsTBP(fs::Real, tiRange::Vector, bwRange::Vector, tbSamples::Real, lobeCount::Real;
                         plot::Bool = false, axis = false, label = "Sigmoid", title = "Sigmoid SLL over TBP", figure = false,
                         color = :blue, scalingParameter::Real = 1)

    # Prepare data.
    SLLvector = Array{Float32}(undef, tbSamples)
    TBPvector = Array{Float32}(undef, tbSamples)
    tiVector = Array{Float32}(undef, tbSamples)
    tiIncrements = (tiRange[2] - tiRange[1]) / tbSamples
    bwIncrements = (bwRange[2] - bwRange[1]) / tbSamples
    if tiIncrements == 0
        tiVector .= tiRange[2]
    else
        tiVector = tiRange[1]:tiIncrements:tiRange[2]
    end

    bwVector = bwRange[1]:bwIncrements:bwRange[2]

    # Create vector.
    for i in 1:1:tbSamples
        nSamples = floor(Int, tiVector[i] * fs)
        signal, null = generateSigmoidWaveform(fs, bwVector[i], nSamples, plot = false, scalingParameter = scalingParameter)
        mf = plotMatchedFilter(0, signal, [], fs, plot = false)
        SLLvector[i] = calculateSideLobeLevel(mf, lobeCount)
        TBPvector[i] = bwVector[i] * tiVector[i] 
    end

    # Plotting.
    if plot
        if axis == false
            ax = Axis(figure[1, 1], xlabel = "TBP (Hz * s)", ylabel = "SLL (dB)", title = title)
            scatterlines!(TBPvector, SLLvector, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
            tbpInc = bwIncrements * tiIncrements
            xlims!(TBPvector[1] - tbpInc, TBPvector[tbSamples] + tbpInc)
        else
            ax = axis
        end
    else
        ax = nothing
    end 

    # Done.
    return TBPvector, SLLvector, ax

end

function sigmoidPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount;
                     axis = false, title = "Sigmoid Plane", plot = true, figure = false)

    # Parameter vector.
    parameterIncrements = ( parameterRange[2] - parameterRange[1] ) / (parameterSamples-1)
    parameterVector = collect(parameterRange[1]:parameterIncrements:parameterRange[2])

    # Generate matrix.
    TBPvector = Array{Float32}(undef, tbSamples)
    sigmoidSLLTBPMatrix = Array{Float32}(undef, 0)
    for pScale in parameterVector

        TBPvector, SLLVector, ax = sigmoidSLLvsTBP(fs, tiRange, bwRange, tbSamples, lobeCount, plot = false, figure = figure, scalingParameter = pScale)
        append!(sigmoidSLLTBPMatrix, SLLVector)

    end
    sigmoidSLLTBPMatrix = reshape(sigmoidSLLTBPMatrix, (tbSamples, parameterSamples))

    # Axis.
    if axis == false
        ax = Axis3(figure[1, 1], xlabel = "TBP (Hz×s)", ylabel = "Non-Linearity",zlabel = "SLL (dB)", title = title)
    else
        ax = axis
    end
    # Plot.
    if plot
        surface!(TBPvector, parameterVector, sigmoidSLLTBPMatrix)
        xlims!(TBPvector[1], TBPvector[tbSamples])
        ylims!(parameterVector[1], parameterVector[parameterSamples])
        zlims!(minimum(sigmoidSLLTBPMatrix), maximum(sigmoidSLLTBPMatrix))
    end
    # Done.
    return sigmoidSLLTBPMatrix, TBPvector, ax

end