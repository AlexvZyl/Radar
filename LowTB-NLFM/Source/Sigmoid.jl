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

norm(m) = ( 1 )/( 1 + exp(-1/m) ) - 0.5
logit(x; m = 1, BW = 2) = -m * log(ℯ, (norm(m)*x + 0.5)^-1 - 1) * BW/2

function logitFreq(BW::Real, nSamples::Real, scale::Real)

    time = -1:2/(nSamples-1):1
    logit.(time, m = scale, BW = BW)

end

function logitPhase(fs::Real, BW::Real, scale::Real, nSamples::Real)

    phase = Array{Float32}(undef, nSamples)
    time = -1:2/(nSamples-1):1
    phase[1] = 0
    for i in 2:1:nSamples-1
        phase[i], err = quadgk(x -> logit(x, m = scale, BW = BW), time[1], time[i], rtol = 1e-6)
    end
    phase[nSamples] = 0
    # Scale the integral, since the time is not from -1 to 1.
    phase .*= (nSamples / fs) / 2
    return phase

end

function generateSigmoidWaveform(fs::Number, BW::Number, nSamples::Real;
                                 plot::Bool = false, axis = false, label = "Sigmoid", figure = false, color = :blue, title = "Sigmoid NFLM",
                                 scalingParameter::Real = 1)

    scalingParameter = exp(1 - scalingParameter)

    # Calculate vectors.
    phase = logitPhase(fs, BW, scalingParameter, nSamples)

    # Plotting.
    unitTime = 0:1/(nSamples-1):1
    if plot        
        freq = logitFreq(BW, nSamples, scalingParameter)
        if axis == false 
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            scatterlines!(unitTime, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            ylims!(-BW/(1e6*2), BW/(1e6*2))
            ax = Axis(figure[1, 2], xlabel = "Time (μs)", ylabel = "Phase (Radians)", title = title)
            scatterlines!(unitTime, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            plotOrigin(ax)
            ax = axis
        else
            # scatterlines!(realTime * 1e6, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
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
                     axis = false, title = "Logit Plane", plot = true, figure = false)

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