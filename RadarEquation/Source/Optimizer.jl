#  This script uses the SNR calculated from the Radar Equation
#  to find which Pulse length yields the highest SNR.

# ----------------------------------- #
# Includes                            #
# ----------------------------------- #

include("Equation.jl")

# ----------------------------------- #
# Optimal Deadzone                    #
# ----------------------------------- #

function findOptimalDeadzone(MinDeadZone::Number, MaxDeadZone::Number, Resolution::Number, SNRThreshold::Number, PlotAnswer::Bool)

    # Radar parameters.
    σ           = dBToAmpl(8)       # sm
    peakPower   = 0.01              # W
    Gantenna²    = dBToAmpl(5.5*2)  # Antenna gain.
    fWave       = 900e6             # Hz
    fSampling   = 16e6              # Hz
    λ²          = (c / fWave)^2     # m²
    bandwidth   = fSampling / 2.1   # MHz
    maxRange    = 400               # m
    deadZone    = 120               # m
    CPI         = 2                 # s
    resolution  = 1                 # m (Range resolution of the graph)
    # Deadzones to be checked.
    deadZones = collect(MinDeadZone:Resolution:MaxDeadZone)
    # Iterate through deadzones.
    for DZ in deadZones
         # Calculate SNR.
         R, SNR = calculateSNR(DZ, maxRange, resolution, CPI,
                               fSampling, fWave, λ², bandwidth,
                               peakPower, Gantenna², σ)
        # Find the distance the radar can detect.
        for i = 1:length(R)
            
        end
    end
    # Plot best solution.
    if PlotAnswer
        plotSNR(R, SNR)
    end

    return optimalDeadzone
end

optimalDeadzone = findOptimalDeadzone(0, 200, 1, 20, true)

# ----------------------------------- #
