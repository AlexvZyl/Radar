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
# Calculate the phase difference, assuming a flat earth.
# λ: Wavelength.
# ΔR: Difference between direct and indirect path.
ΔΦ(λ, ΔR) = (2π / λ) * ΔR

# (N/A)
# Calculate α.
α(ΔΦ, ϕ) = ΔΦ + ϕ

# (8.25)
# Calculate the propagation factor.
# ρ: Is the aperture efficiency (less than unity).
# α: See previous function.
F(ρ, α) = sqrt( 1 + ρ^2 + 2 * ρ * cos(α) )

#-------------------#
# Round Earth Model #
#-------------------#

# Required variables:
# See Fig. 8.11 for descriptions.
# ht: Height of target.
# hr: Height of radar.
# ϕ1: Radar to reflection point from center of earth.
# ϕ2: Target to reflection point from center of earth.

# Radius of the earth.
global const k = 1 # What is this constant supposed to be?
global const r0 = 6371000
global const re = k * r0

# (N/A)
# Calculate the total angle.
# Parameters described in required parameters.
ϕ(ϕ1, ϕ2) = ϕ1 + ϕ2

# (8.51)
# See Fig. 8.11 for description and parameters.
R1(hr, ϕ1) = sqrt( hr^2 + 4*re*(re+hr)*(sin(ϕ1/2))^2 )

# (8.52)
# See Fig. 8.11 for description and parameters.
R2(ht, ϕ2) = R1_re(ht, re, ϕ2)

# (8.53)
# See Fig. 8.11 for description and parameters.
Rd(ht, hr, ϕ1, ϕ2) = sqrt( (ht-hr)^2 + 4*(re+ht)*(re+hr)*(sin((ϕ1+ϕ2)/2)^2) )

# (8.55)
# See Fig. 8.11 for description and parameters.
# Note: This is not from Mahafza, but from Blake.
ψg(ht, R1) = asin( (ht/R1) - (R1/2*re) )

# (8.54)
# Calculate the difference in distance between the direct and indirect paths,
# assuming a round earth.
# See Fig. 8.11 for parameters.
# Note: This is not from Mahafza, but from Blake.
ΔR(R1, R2, Rd, ψg) = (4 * R1 * R2 * (sin(ψg)^2) ) / (R1 + R2 + Rd)

# -------------- #
# Implementation #
# -------------- #
