# All of the equations are from Mahafza, Radar Systems Analysis and Design Using MATLAB.

# Notes:
# ------
# Multipath is worse near the surface of the earth.
# ------

# Define the complex number.
const j = complex(0, 1)

#----------------------------#
# Pattern Propagation Factor #
#----------------------------#

# (8.18)
# Calculate the phase difference.
# λ: Wavelength.
# ΔR: Difference between direct and indirect path.
ΔΦ(λ, ΔR) = (2π / λ) * ΔR

# (N/A)
# Calculate α.
# ϕ:
# ΔΦ:
α(ΔΦ, ϕ) = ΔΦ + ϕ

# (8.25)
# Calculate the propagation factor.
# ρ: The aperture efficiency of the antenna (less than unity).
# α: See previous function.
F(ρ, α) = sqrt( 1 + ρ^2 + 2 * ρ * cos(α) )

# (N/A)
# Calculate the loss due to the propagation factor.
# F: Propagation factor.
loss(F) = F^4 

#-------------------#
# Round Earth Model #
#-------------------#

# Radius of the earth.
global const k = 1 # What is this constant supposed to be?
global const r0 = 6371000 # Actual radius.
global const re = k * r0  # Effective radius.

# (8.47)
# Calculate the angle: radar to reflection point from center of earth.
# r1: See Fig. 8.11.
ϕ1(r1) = r1 / re

# (8.47)
# Calculate the angle: target to reflection point from center of earth.
# r2: See Fig. 8.11.
ϕ2(r2) = ϕ1(r2)

# (N/A)
# Calculate the total angle.
# Parameters described in required parameters.
ϕ(ϕ1, ϕ2) = ϕ1 + ϕ2

# (8.51)
# See Fig. 8.11 for description and parameters.
R1(hr, ϕ1) = sqrt( hr^2 + 4*re*(re+hr)*(sin(ϕ1/2))^2 )

# (8.52)
# See Fig. 8.11 for description and parameters.
R2(ht, ϕ2) = R1(ht, ϕ2)

# (8.53)
# See Fig. 8.11 for description and parameters.
Rd(ht, hr, ϕ1, ϕ2) = sqrt( (ht-hr)^2 + 4*(re+ht)*(re+hr)*(sin((ϕ1+ϕ2)/2)^2) )

# (8.55)
# See Fig. 8.11 for description and parameters.
# Note: This is not from Mahafza, but from Blake.
ψg(ht, R1) = asin( ht/R1 - R1/(2*re) )

# (8.54)
# Calculate the difference in distance between the direct and indirect paths,
# assuming a round earth.
# See Fig. 8.11 for parameters.
# Note: This is not from Mahafza, but from Blake.
ΔR(R1, R2, Rd, ψg) = (4 * R1 * R2 * (sin(ψg)^2) ) / (R1 + R2 + Rd)

# -------------- #
# Implementation #
# -------------- #

# Speed of light (m/s).
global const c = 299792458 

# (N/A)
# Calculate the wavelength.
# ft: Transmission frequency.
λ(ft) = c / ft

# Calculate the loss caused by the multipath.
# ht: Height of target.
# hr: Height of radar.
# r1: Radial distance between radar and reflection point.
# r2: Radial distance between target and reflection point.
# ft: Transmission frequency.
function calculate_multipath_loss(ht::Number, hr::Number, r1::Number, r2::Number, ft::Number;
                                  dB::Bool = true, ρ::Number = 0.9)
    
    # Calculate the parameters.
    _λ= λ(ft)    
    _ϕ1 = ϕ1(r1)
    _ϕ2 = ϕ2(r2)
    _R1 = R1(hr, _ϕ1)
    _R2 = R2(ht, _ϕ2)
    _Rd = Rd(ht, hr, _ϕ1, _ϕ2)
    _ψg = ψg(ht, _R1)
    _ΔR = ΔR(_R1, _R2, _Rd, _ψg)
    _ΔΦ = ΔΦ(_λ, _ΔR)
    _ϕ  = ϕ(_ϕ1, _ϕ2)
    _α  = α(_ΔΦ, _ϕ)
    _F  = F(ρ, _α)

    # Return the loss.
    if !dB return loss(_F) end
    return 20*log10(loss(_F))

end
