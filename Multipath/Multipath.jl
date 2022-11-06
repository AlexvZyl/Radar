# All of the equations are from Mahafza, Radar Systems Analysis and Design Using MATLAB.

# Notes:
# ------
# Multipath is worse near the surface of the earth.
# ------

using CoordinateTransformations
using StaticArrays
include("../Utilities/MakieGL/MakieGL.jl")

# Define the complex number.
const j = complex(0, 1)

#----------------------------#
# Pattern Propagation Factor #
#----------------------------#

# (8.18)
# Calculate the phase difference.
# λ:  Wavelength.
# ΔR: Difference between direct and indirect path.
ΔΦ(λ, ΔR) = (2π / λ) * ΔR

# (8.19)
# Earth's reflection coefficient.
# ρ: Amplitude loss.
# θ: Phase shift.
Γ(ρ, θ) = ρ * exp( j * θ )

# (N/A)
# Calculate total phase change.
# θ:  Phase shift induced on the indirect path signal due to surface roughness.
# ΔΦ: Phase difference between the two paths.
α(ΔΦ, θ = π) = ΔΦ + θ

# (8.25)
# Calculate the propagation factor.
# ρ: Amplitude loss from surface reflection.
# α: Total phase change.
F(α, ρ = 1) = sqrt( 1 + ρ^2 + 2 * ρ * cos(α) )

# (N/A)
# Calculate the loss due to the propagation factor.
# F: Propagation factor.
loss(F) = F^4

#-------------------#
# Round Earth Model #
#-------------------#

# Radius of the earth.
global const k = 1 # What is this constant supposed to be?
global const r0 = 6371000 # Actual radius (m).
global const re = k * r0  # Effective radius (m).

# (8.44)
# See Fig. 8.11 for description and parameters.
r1(r, p, ξ) = r/2 - p*sin(ξ/3)
# where:
# (8.45)
p(ht, hr, r) = (2/√(3)) * √( re*(ht+hr) + (r/2)^2 )
# (8.46)
ξ(ht, hr, r, p) = asin( (2*re*r*(ht-hr)) / (p^3) )

# (N/A)
# See Fig. 8.11 for description and parameters.
r2(r, r1) = r - r1

# (8.47)
# See Fig. 8.11 for description and parameter.
ϕ1(r1) = r1 / re

# (8.47)
# See Fig. 8.11 for description and parameter.
ϕ2(r2) = ϕ1(r2)

# (N/A)
# Calculate the total angle.
# See Fig. 8.11 for description and parameter.
ϕ(ϕ1, ϕ2) = ϕ1 + ϕ2

# (8.51)
# See Fig. 8.11 for description and parameters.
R1(hr, ϕ1) = √( hr^2 + 4*re*(re+hr)*(sin(ϕ1/2)^2) )

# (8.52)
# See Fig. 8.11 for description and parameters.
R2(ht, ϕ2) = R1(ht, ϕ2)

# (8.53)
# See Fig. 8.11 for description and parameters.
Rd(ht, hr, ϕ1, ϕ2) = sqrt( (ht-hr)^2 + 4*(re+ht)*(re+hr)*(sin((ϕ1+ϕ2)/2)^2) )

# (8.55)
# See Fig. 8.11 for description and parameters.
# Note: This is not from Mahafza, but from Blake.
ψg(ht, R1) = asin( (ht/R1) - (R1/(2*re)) )

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
# ft: Frequency.
λ(f) = c / f

# Calculate the effect caused by the multipath.
# ht: Height of target.
# hr: Height of radar.
# r1: Radial distance between radar and reflection point.
# r2: Radial distance between target and reflection point.
# ft: Transmission frequency.
function calculate_multipath(ht::Number, hr::Number, r::Number, ft::Number; dB::Bool = true) 

    # Calculate the parameters.
    _p = p(ht, hr, r)
    _ξ = ξ(ht, hr, r, _p)
    _r1 = r1(r, _p, _ξ)
    _r2 = r2(r, _r1)
    _λ  = λ(ft)    
    _ϕ1 = ϕ1(_r1)
    _ϕ2 = ϕ2(_r2)
    _R1 = R1(hr, _ϕ1)
    _R2 = R2(ht, _ϕ2)
    _Rd = Rd(ht, hr, _ϕ1, _ϕ2)
    _ψg = ψg(ht, _R1)
    _ΔR = ΔR(_R1, _R2, _Rd, _ψg)
    _ΔΦ = ΔΦ(_λ, _ΔR)
    _α  = α(_ΔΦ)
    _F  = F(_α)

    # Return the loss.
    if !dB return loss(_F) end
    return 20*log10(loss(_F))

end

# Plot the effect of the multipath.
# (Creates a new figure and axis)
# ht: Height of target.
# hr_range: Range of heights for the radar.
# r1: Radial distance between radar and reflection point.
# r2: Radial distance between target and reflection point.
# ft_range: Range of transmission frequencies.
function plot_multipath(ht::Number, hr_range::AbstractRange, r::Number, ft_range::AbstractRange; dB::Bool = true)

    # Setup plotting.
    figure = Figure()
    axis = Axis(figure[1,1], xlabel = "Radar Height (m)", ylabel = "Multipath Factor (dB)", title = "Multipath")

    # Plot for each frequency.
    for ft in ft_range
        loss_vector = calculate_multipath.(ht, hr_range, r, ft, dB = dB)    
        scatterlines!(hr_range, loss_vector, label = string(ft) * " Hz")
    end

    # Display the plot on the screen.
    axislegend(axis)
    display(figure)

end

# Calculate the elevation angles for different target heights.
# This is easier than changing the math in the textbook.
function calculate_elevation_angle(ht::Number, hr::Number, r::Number)
    _p = p(ht, hr, r)
    _ξ = ξ(ht, hr, r, _p)
    _r1 = r1(r, _p, _ξ)
    _ϕ1 = ϕ1(_r1)
    _R1 = R1(hr, _ϕ1)
    return ψg(ht, _R1)
end

# Plot the effect of the multipath.
# (Creates a new figure and axis)
# ht: Range of heights for the target.
# hr: Height of the radar.
# r1: Radial distance between radar and reflection point.
# r2: Radial distance between target and reflection point.
# ft_range: Range of transmission frequencies.
function plot_multipath(ht_range::AbstractRange, hr::Number, r::Number, ft_range::AbstractRange; dB::Bool = true)

    # Setup plotting.
    figure = Figure()
    axis = Axis(figure[1,1], xlabel = "Target Height (m)", ylabel = "Multipath Factor (dB)", title = "Multipath")

    # Plot for each frequency.
    for ft in ft_range
        loss_vector = calculate_multipath.(ht_range, hr, r, ft, dB = dB)    
        scatterlines!(ht_range, loss_vector, label = string(ft) * " Hz")
    end

    # Display the plot on the screen.
    axislegend(axis)
    display(figure)

end

# Get a full elevation angles vector with the corresponding target height.
function _lobe_structure_polar(hr::Number, r::Number, ft::Number;
                               height_resolution::Number = 0.001, normalise_mp::Bool = true)

    # If the loop should continue.
    should_cont = true
    ht = 0
    polar_coords = Vector{Polar}(undef, 0)
    max_mp = -Inf

    # Calculate the values.
    # This while loop is very sketchy programming.
    while(should_cont)

        # Try to calculate the polar coord.
        try
            mp = calculate_multipath(ht, hr, r, ft, dB = false) 
            # Keep track of the max.
            if mp > max_mp
                max_mp = mp
            end
            ea = calculate_elevation_angle(ht, hr, r)
            ht += height_resolution
            push!(polar_coords, Polar(mp, ea))
            
        # This will occur when the angle goes past 90 deg.
        catch 
            should_cont = false 
        end

    end 

    # Do not normalise.
    if !normalise_mp 
        return polar_coords
    end

    # Normalise the mp.
    for (i, coord) in enumerate(polar_coords)
        polar_coords[i] = Polar(coord.r / max_mp, coord.θ)
    end
    return polar_coords
    
end

# Plot the effect of the multipath.
# (Creates a new figure and axis)
# ht: Height of target.
# hr_range: Range of heights for the radar.
# r1: Radial distance between radar and reflection point.
# r2: Radial distance between target and reflection point.
# ft_range: Range of transmission frequencies.
function plot_lobe_structure(hr::Number, r::Number, ft_range::AbstractRange)

    # Setup plotting.
    figure = Figure()
    axis = Axis(figure[1,1], xlabel = "θ = Elevation Angle", ylabel = "R = Normalised Propagation Factor", title = "Multipath")

    # Plot for each frequency.
    for ft in ft_range
        polar_coords = _lobe_structure_polar(hr, r, ft) 
        cartesian_coords = CartesianFromPolar().(polar_coords)
        x = [ coord[1] for coord in cartesian_coords ]
        y = [ coord[2] for coord in cartesian_coords ]
        scatterlines!(x, y, label = string(ft) * " Hz")
    end

    # Display the plot on the screen.
    axislegend(axis)
    display(figure)

end