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

sigmoid(x, scale) = 1 ./ ( 1 .+ exp.(-1 .* scale .* x) )
logit(x; normValue = 1, m=1, c=0) = ( (-1/m) * log(ℯ, ( (x^-1) -1 )) + c ) / normValue

function logitFreq(time, fs::Real, BW::Real, scale::Real, nSamples::Real; onlyFreq::Bool = false)

    # Calculate logit frequency.   
    normValue = abs(logit(time[1], m=scale)) * 2 / BW
    freq = logit.(time, m=scale, normValue=normValue)

    return freq

    # Range the freq in BW.
    freq = freq ./ maximum(abs.(freq))
    freq .*= (BW / 2)
 
    # Return.
    return freq

end

function logitPhase(time, fs::Real, BW::Real, scale::Real, nSamples::Real)

    phase = Array{Float32}(undef, nSamples)
    normValue = abs(logit(time[1], m=scale)) * 2 / BW
    timeScale = ( (nSamples/fs) / (time[end]-time[1]) )
    for i in 1:1:nSamples
        phase[i], err = quadgk(x -> logit(x, normValue=normValue, m=scale), time[1], time[i], rtol = 1e-3)
    end
    return phase

end

function generateSigmoidWaveform(fs::Number, BW::Number, nSamples::Real;
                                 plot::Bool = false, axis = false, label = "Sigmoid", figure = false, color = :blue, title = "Sigmoid NFLM",
                                 scalingParameter::Real = 1)

    # Create time vector.
    startTime = 0.5 - scalingParameter * 0.5
    endTime = 0.5 + scalingParameter * 0.5
    increment = (endTime-startTime)/(nSamples+1)
    time = collect(startTime:increment:endTime)
    # Ensure we do not have a 0 or 1.
    pop!(time)
    popfirst!(time)
    
    # Calculate vectors.
    freq = logitFreq(time, fs, BW, 1, nSamples)
    phase = logitPhase(time, fs, BW, 1, nSamples)

    # Since we have to scale the values from 0 to 1 to fit it into the logit function
    # the phase has to be scaled so that we can get the correct integral.
    logitTime = endTime - startTime;
    timeScale = (nSamples/fs) / logitTime
    phase .*= timeScale

    # Plotting.
    realTime = (0:1:(nSamples-1))/fs
    if plot        
        if axis == false 
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            scatterlines!(time, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            ax = Axis(figure[1, 2], xlabel = "Time (μs)", ylabel = "Phase (Radians)", title = title)
            scatterlines!(realTime * 1e6, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
        else
            scatterlines!(realTime * 1e6, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            ax = axis
        end
    else
        ax = nothing
    end 

    # Return signal
    return exp.(im * phase * 2π), ax

end

function sigmoidSLLvsTBP(fs::Real, tiRange::Vector, bwRange::Vector, tbSamples::Real, lobeCount::Real;
                         plot::Bool = false, axis = false, label = "Sigmoid", title = "Sigmoid SLL over TBP", figure = false,
                         color = :blue, scalingParameter::Real = 1)

    # Prepare data.
    SLLvector = Array{Float32}(undef, tbSamples)
    TBPvector = Array{Float32}(undef, tbSamples)
    tiVector = Array{Float32}(undef, tbSamples)
    tiIncrements = (tiRange[2] - tiRange[1]) / (tbSamples-1)
    bwIncrements = (bwRange[2] - bwRange[1]) / (tbSamples-1)
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
    parameterVector = parameterRange[1]:parameterIncrements:parameterRange[2]

    # Generate matrix.
    tbpRange = [tiRange[1]*bwRange[1], tiRange[end]*bwRange[end]]
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
        ax.azimuth = pi/2 - pi/4
    else
        ax = axis
    end
    # Plot.
    if plot
        surface!(TBPvector, parameterVector, sigmoidSLLTBPMatrix)
        xlims!(tbpRange[1], tbpRange[2])
        ylims!(parameterRange[1], parameterRange[2])
        zlims!(minimum(sigmoidSLLTBPMatrix), maximum(sigmoidSLLTBPMatrix))
    end

    # Setup the camera.
    # translate_cam!(ax.scene, [1,1,1])

    # Done.
    return sigmoidSLLTBPMatrix, TBPvector, ax

end

function plotSigmoid()
    inc = 0.01
    values = -1:inc:1
    wave = sigmoid(values, 10)
    ax = Axis(figure[1, 1], xlabel = "", ylabel = "", title = "Sigmoid Function")
    scatterlines!(values, wave, linewidth = lineThickness, markersize = dotSize, color = :blue)
    plotOrigin(ax)
end