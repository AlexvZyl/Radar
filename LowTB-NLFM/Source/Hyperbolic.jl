include("../../Utilities/MakieGL/MakieGL.jl")
include("Utilities.jl")
using QuadGK

normHyper(m) = log(ℯ, 1/m + sqrt((1/m)^2 + 1) )
Hyperbolic(x; m=1, BW = 2) = m * sinh( normHyper(m) * x ) * BW/2

function HyperbolicFreq(BW::Real, nSamples::Real, scale::Real)
    time = -1:2/(nSamples-1):1
    return Hyperbolic.(time, m = scale, BW = BW)
end

function HyperbolicPhase(fs::Real, BW::Real, scale::Real, nSamples::Real)

    phase = Array{Float32}(undef, nSamples)
    time = -1:2/(nSamples-1):1
    phase[1] = 0
    phase[nSamples] = 0
    for i in 2:1:nSamples-1
        phase[i], err = quadgk(x -> Hyperbolic(x, m = scale, BW = BW), time[1], time[i], rtol = 1e-3)
    end
    # Scale the integral, since the time is not from -1 to 1.
    phase .*= (nSamples / fs) / 2
    return phase

end

function generateHyperbolicWaveform(fs::Number, BW::Number, nSamples::Real;
                                 plot::Bool = false, axis = false, label = "Hyperbolic", figure = false, color = :blue, title = "Hyperbolic NFLM",
                                 scalingParameter::Real = 1)

    scalingParameter = exp(1 - scalingParameter)

    # Calculate vectors.
    phase = HyperbolicPhase(fs, BW, scalingParameter, nSamples)

    # Plotting.
    unitTime = 0:1/(nSamples-1):1
    if plot        
        freq = HyperbolicFreq(BW, nSamples, scalingParameter)
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

function HyperbolicSLLvsTBP(fs::Real, tiRange::Vector, bwRange::Vector, tbSamples::Real, lobeCount::Real;
                         plot::Bool = false, axis = false, label = "Hyperbolic", title = "Hyperbolic SLL over TBP", figure = false,
                         color = :blue, scalingParameter::Real = 1)

    # Prepare data.
    SLLvector = Array{Float32}(undef, tbSamples)
    TBPvector = Array{Float32}(undef, tbSamples)
    tiVector = Array{Float32}(undef, tbSamples)
    bwVector = Array{Float32}(undef, tbSamples)
    tiIncrements = (tiRange[2] - tiRange[1]) / (tbSamples-1)
    bwIncrements = (bwRange[2] - bwRange[1]) / (tbSamples-1)

    if tbSamples == 1
        tiVector[1] = tiRange[1]
    elseif tiIncrements == 0
        tiVector .= tiRange[2]
        tiVector = tiRange[1]:tiIncrements:tiRange[2]
    end

    if tbSamples == 1
        bwVector[1] = bwRange[1]
    elseif bwIncrements == 0
        bwVector .= bwRange[2]
    else
        bwVector = bwRange[1]:bwIncrements:bwRange[2]
    end

    # Create vector.
    for i in 1:1:tbSamples
        nSamples = floor(Int, tiVector[i] * fs)
        signal, null = generateHyperbolicWaveform(fs, bwVector[i], nSamples, plot = false, scalingParameter = scalingParameter)
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

function HyperbolicPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples, lobeCount;
                     axis = false, title = "Hyperbolic Plane", plot = true, figure = false)

    # Parameter vector.
    parameterIncrements = ( parameterRange[2] - parameterRange[1] ) / (parameterSamples-1)
    parameterVector = parameterRange[1]:parameterIncrements:parameterRange[2]

    # Generate matrix.
    tbpRange = [tiRange[1]*bwRange[1], tiRange[end]*bwRange[end]]
    TBPvector = Array{Float32}(undef, tbSamples)
    HyperbolicSLLTBPMatrix = Array{Float32}(undef, 0)
    for pScale in parameterVector

        TBPvector, SLLVector, ax = HyperbolicSLLvsTBP(fs, tiRange, bwRange, tbSamples, lobeCount, plot = false, figure = figure, scalingParameter = pScale)
        append!(HyperbolicSLLTBPMatrix, SLLVector)

    end
    HyperbolicSLLTBPMatrix = reshape(HyperbolicSLLTBPMatrix, (tbSamples, parameterSamples))

    # Axis.
    if axis == false && plot
        ax = Axis3(figure[1, 1], xlabel = "TBP (Hz×s)", ylabel = "Non-Linearity",zlabel = "SLL (dB)", title = title)
        ax.azimuth = pi/2 - pi/4
    else
        ax = axis
    end
    # Plot.
    if plot
        surface!(TBPvector, parameterVector, HyperbolicSLLTBPMatrix)
        xlims!(tbpRange[1], tbpRange[2])
        ylims!(parameterRange[1], parameterRange[2])
        zlims!(minimum(HyperbolicSLLTBPMatrix), maximum(HyperbolicSLLTBPMatrix))
    end

    # Done.
    return HyperbolicSLLTBPMatrix, TBPvector, ax

end

function plotHyperbolic(m)
    nSamples = 165
    freq = HyperbolicFreq(2, nSamples, exp(1-m))
    ax = Axis(figure[1, 1], xlabel = "", ylabel = "", title = "Hyperbolic Function")
    values = -1:2/(nSamples-1):1
    scatterlines!(values, freq, linewidth = lineThickness, markersize = dotSize, color = :blue)
    plotOrigin(ax)
end

function OptimisedHyperbolicSLL(BW::Real, fs::Real, nSamples::Real; 
                                range::Vector = [0, 5], parameterSamples = 100, lobeCount::Real = 10)

    ti = nSamples / fs
    SLL = HyperbolicPlane(fs, [ti, ti], [BW, BW], range, parameterSamples, 1, lobeCount, plot = false)[1]
    paramRange = range[2] - range[1]
    parameterVec = range[1]:paramRange/(parameterSamples-1):range[2]
    val, index = findmin(SLL)
    minParam = parameterVec[index[2]]
    println("Minimised SLL Parameter (hyperbolic): ", minParam)
    return minParam
end