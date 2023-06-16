# ---------------------------------------------------------------------------- #
#  The Radar Equation                                                          #
# ---------------------------------------------------------------------------- #

# This is to be used for estimating the distance at which the radar
# can detect targets at different SNR levels.  This script will be
# run with the EttusB210 Interface application.
#
# The equation:
#
#           G²ₐ * Eₚ * σ * λ² * PC * FFT
# SNR  =   -------------------------------
#               R⁴ * (4π)³ * Lₜ * Pₙ

# ---------------------------------------------------------------------------- #
# Setup                                                                        #
# ---------------------------------------------------------------------------- #

using GLMakie
set_theme!(theme_dark())
update_theme!(
  Axis = (
    leftspinevisible = true,
    rightspinevisible = true,
    topspinevisible = true,
    bottomspinevisible = true,
    bottomspinecolor = :gray90,
    topspinecolor = :gray90,
    leftspinecolor = :gray90,
    rightspinecolor = :gray90
    )
  )

# ---------------------------------------------------------------------------- #
#  Constants                                                                   #
# ---------------------------------------------------------------------------- #

# General parameters.
c           = 299792458         # m/s (Speed of light)
k           = 1.38e-23          # Boltzmann constant
T           = 293               # K

# ---------------------------------------------------------------------------- #
#  Conversions.                                                                #
# ---------------------------------------------------------------------------- #

function amplTodB(amplitude::Number)
  20*log10(amplitude)
end

function powerTodB(power::Number)
  10*log10(power)
end

function dBToAmpl(dbValue::Number)
  10^(dbValue/20)
end

function dBToPower(dbValue::Number)
  10^(dbValue/10)
end

# ---------------------------------------------------------------------------- #
# Graph.                                                                       #
# ---------------------------------------------------------------------------- #

function plotSNR(Range::Vector, SNR::Vector)

  textSize = 23
  lineThickness = 4
  dashThickness = 2.5
  dotSize = 5
  originThickness = 2
  f = Figure()
  ax = Axis(f[1, 1], xlabel = "Range (m)", ylabel = "SNR (dB)", title = "Radar Range Equation",
            titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)
  
  ylims!(ax, -20, 100)
  vlines!(ax, 0, color = :white, linewidth=originThickness)
  hlines!(ax, 0, color = :white, linewidth=originThickness)
  plt0 = lines!(Range, SNR, color = :blue, linewidth=lineThickness)
  # plt1 = scatter!(R, SNR, color = :turquoise, markersize=dotSize)
  DZ   = vlines!(ax, deadZone, color = :red, linewidth=dashThickness, linestyle = :dash)
  db30 = hlines!(ax, 30, color = :green, linewidth=dashThickness, linestyle = :dash)
  db20 = hlines!(ax, 20, color = :yellow, linewidth=dashThickness, linestyle = :dash)
  legend = Legend(
      f[1,2],
      [plt0, DZ, db30, db20],
      ["Radar SNR", "Deadzone", "30dB", "20dB"],
      labelsize = textSize
  )
  display(f)

end # Function.

# ---------------------------------------------------------------------------- #
#  SNR Calculation.                                                            #
# ---------------------------------------------------------------------------- #

function calculateSNR(deadZone, maxRange, resolution, CPI,
                      fSampling, fWave, λ², bandiwdth,
                      peakPower, Gantenna², σ)

  # Derived parameters.
  txWaveLength    = round( ( (deadZone*2)/c ) * fSampling )   # Pulse length (transmission without zeros).
  pulseLength     = round( ( (maxRange*2)/c ) * fSampling )   # One transmission with zeros.
  totalPulses     = round( (fSampling * CPI) / pulseLength )  # Total pulses in one transmission.
  fftBits         = floor(log2(totalPulses))                  # ALl of the pulses have to fit in the FFT.
  gainFFT         = 2^fftBits                                 #
  noiseLoss       = powerTodB(k*T*bandiwdth)                  # dB
  waveDuration    = (2*deadZone)/c;                           # s
  pulseEnergy     = waveDuration * peakPower                  # J
  PCgain          = waveDuration * bandiwdth                  # Gain from pulse compression.
  totalLosses     = dBToAmpl(2.5)                             # General losses.
  # Range vector.
  R = collect(0:resolution:maxRange)
  # Equation.
  num         =       Gantenna² * pulseEnergy * totalPulses * σ * λ² * gainFFT * PCgain
  #                 ----------------------------------------------------------------------
  den         =               R.^4 * (4π)^3 * dBToAmpl(noiseLoss) * totalLosses
  # SNR.
  SNR = vec(amplTodB.(num ./ den))
  return R, SNR

end # Function

# ---------------------------------------------------------------------------- #
#  Script.                                                                     #
# ---------------------------------------------------------------------------- #

# Radar parameters.
σ           = dBToAmpl(8)       # sm
peakPower   = 0.01              # W
Gantenna²    = dBToAmpl(5.5*2)  # Antenna gain.
fSampling   = 16e6              # Hz
fWave       = 900e6             # Hz
λ²          = (c / fWave)^2     # m²
bandwidth   = fSampling / 2.1   # MHz
maxRange    = 400               # m
deadZone    = 120               # m
CPI         = 2                 # s
resolution  = 1                 # m (Range resolution of the graph)

R, SNR = calculateSNR(deadZone, maxRange, resolution, CPI,
                      fSampling, fWave, λ², bandwidth,
                      peakPower, Gantenna², σ)
plotSNR(R, SNR)

# ---------------------------------------------------------------------------- #
