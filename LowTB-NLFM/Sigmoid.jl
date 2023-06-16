include("../../Utilities/MakieGL/MakieGL.jl")
include("Utilities.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
using QuadGK

sigmoid(x, scale) = 1 ./ ( 1 .+ exp.(-1 .* scale .* x) )
normLogit(m) = ( 1 )/( 1 + exp(-1/m) ) - 0.5
logit(x; m = 1, BW = 2) = -m * log(ℯ, ( normLogit(m)*x + 0.5 )^-1 - 1) * BW/2

function logitFreq(BW::Real, nSamples::Real, scale::Real)
    time = -1:2/(nSamples-1):1
    return logit.(time, m = scale, BW = BW)
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
                                 scalingParameter::Real = 1, durationScale = 1)

    scalingParameter = exp(1 - scalingParameter)

    # Calculate vectors.
    phase = logitPhase(fs, BW, scalingParameter, nSamples)

    # Plotting.
    unitTime = 0:1/(nSamples-1):(1 - 1/(nSamples-1))
    if plot        
        freq = logitFreq(BW, nSamples-1, scalingParameter)
        if axis == false 
            ax = Axis(figure[1, 1], xlabel = "Time (μs)", ylabel = "Frequency (MHz)", title = title)
            scatterlines!(unitTime, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            # ylims!(-BW/(1e6*2), BW/(1e6*2))
            # ax = Axis(figure[1, 2], xlabel = "Time (μs)", ylabel = "Phase (Radians)", title = title)
            # scatterlines!(unitTime, phase, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            # plotOrigin(ax)
            ax = axis
        else
            scatterlines!(unitTime * durationScale, freq ./ 1e6, linewidth = lineThickness, color = color, markersize = dotSize, label = label)
            ax = axis
        end
    else
        ax = nothing
    end 

    # Return signal
    return exp.(im * phase * 2π), ax

end

function sigmoidSLLvsTBP(fs::Real, tiRange::Vector, bwRange::Vector, tbSamples::Real;
                         plot::Bool = false, axis = false, label = "Sigmoid", title = "Sigmoid SLL over TBP", figure = false,
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
        if tiIncrements != 0
            tiVector = tiRange[1]:tiIncrements:tiRange[2]
        end
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
        signal, null = generateSigmoidWaveform(fs, bwVector[i], nSamples, plot = false, scalingParameter = scalingParameter)
        mf = plotMatchedFilter(0, signal, [], fs, plot = false)
        SLLvector[i] = calculateSideLobeLevel(mf)
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

function sigmoidPlane(fs, tiRange, bwRange, parameterRange, parameterSamples, tbSamples;
                     axis = false, title = "Logit Plane", plot = true, figure = false)

    # Parameter vector.
    parameterIncrements = ( parameterRange[2] - parameterRange[1] ) / (parameterSamples-1)
    parameterVector = parameterRange[1]:parameterIncrements:parameterRange[2]

    # Generate matrix.
    tbpRange = [tiRange[1]*bwRange[1], tiRange[end]*bwRange[end]]
    TBPvector = Array{Float32}(undef, tbSamples)
    sigmoidSLLTBPMatrix = Array{Float32}(undef, 0)
    for pScale in parameterVector
        TBPvector, SLLVector, ax = sigmoidSLLvsTBP(fs, tiRange, bwRange, tbSamples, plot = false, figure = figure, scalingParameter = pScale)
        append!(sigmoidSLLTBPMatrix, SLLVector)
    end
    sigmoidSLLTBPMatrix = reshape(sigmoidSLLTBPMatrix, (tbSamples, parameterSamples))

    # Axis.
    if axis == false && plot
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

    # Done.
    return sigmoidSLLTBPMatrix, TBPvector, ax

end

function plotSigmoid(m)
    BW = 2
    nSamples = 165
    freq = logitFreq(BW, nSamples, exp(1-m))
    time = -1:2/(nSamples-1):1
    ax = Axis(figure[1, 1], xlabel = "", ylabel = "", title = "Sigmoid Function")
    scatterlines!(time, freq, linewidth = lineThickness, markersize = dotSize, color = :blue)
    plotOrigin(ax)
end


# Get the scaling parameter for a sigmoid optimised for SLL in the given range.
function OptimisedSigmoidSLL(BW::Real, fs::Real, nSamples::Real; 
                             range::Vector = [0, 5], parameterSamples = 100, lobeCount::Real = 10)

    ti = nSamples / fs
    SLL = sigmoidPlane(fs, [ti, ti], [BW, BW], range, parameterSamples, 1, lobeCount, plot = false)[1]
    paramRange = range[2] - range[1]
    parameterVec = range[1]:paramRange/(parameterSamples-1):range[2]
    val, index = findmin(SLL)
    minParam = parameterVec[index[2]]
    println("Minimised SLL Parameter (sigmoid): ", minParam)
    optimalSigmoid, ax = generateSigmoidWaveform(fs, BW, nSamples, scalingParameter = minParam)
    sigmoidMF = plotMatchedFilter(0, optimalSigmoid, [], fs, plot = false)
    println("SLL: ", calculateSideLobeLevel(sigmoidMF))
    println("MLW: ", calculateMainLobeWidth(sigmoidMF) / fs * BW )
    return minParam

end

function generateOptimalSigmoidForSDR(nSamples::Int32, BW::Float64, fs::Int32; formatJulia = false)
    
    # Default parameters.
    range = [0, 5]
    parameterSamples = 5000
    lobeCount = 0 # This parameter is deprecated.

    # Calculate the optimal waveform.
    ti = nSamples / fs
    SLL = sigmoidPlane(fs, [ti, ti], [BW, BW], range, parameterSamples, 1, lobeCount, plot = false)[1]
    paramRange = range[2] - range[1]
    parameterVec = range[1]:paramRange/(parameterSamples-1):range[2]
    val, index = findmin(SLL)
    minParam = parameterVec[index[2]]
    
    # Generate the optimal waveform.
    complexWave, ax = generateSigmoidWaveform(fs, BW, nSamples, scalingParameter = minParam)
    
    # Return for Julia format.
    if formatJulia == true
       return complexWave 
    end

    # Return for C++ format.
    floatWave = Vector{Float64}(undef, nSamples*2)
    floatWave[1:2:end-1] =  Float64.(real.(complexWave))
    floatWave[2:2:end] =  Float64.(imag.(complexWave))
    return floatWave

end
