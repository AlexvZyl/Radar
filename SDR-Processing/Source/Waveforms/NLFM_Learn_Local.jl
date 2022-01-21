# ----------------- #
#  P L O T T I N G  #
# ----------------- #

include("../../../Utilities/MakieGL.jl")

# --------------- #
#  M O D U L E S  #
# --------------- #

using DSP
using PlutoUI
using StatsBase
using Zygote

# --------------------- #
#  P A R A M E T E R S  #
# --------------------- #

# The plot.
fig = Figure()
ax = Axis(fig[1, 1], xlabel = "Time (μs)", ylabel = "Magnitude (dB)", title = "Matched Filter Response",
 								titlesize = textSize, ylabelsize=textSize, xlabelsize=textSize)

enable_norm_freq_plot = false
enable_freq_plot = false
enable_autocorr_plot = false
enable_phase_plot = true

# Duration and bandwidth of the chirp.
t_i = 10e-6
BW = 32e6

# Sampling frequency.
fs = 16e6

# B changes the "intensity" of the non-linearty of the chirp. The valid range is 0 < B < 2,
# with B closer to 0 giving close to a linear chirp and B close to 2 giving very rapid chirp
# rate near the start and end of the pulse. The useful or interesting range is 1 < B < 1.99,
# with B close to 1 giving a very subtle non-linear chirp and specify B via a square root function,
# i.e. ``B = \sqrt{x}``, to get finer increments near 2 than near 1.
x = 3.6
# From the Pluto slider:
# x = $(@bind x Slider(range(1, 4, step = 0.05), default = 3.6, show_value = true))

B = min(sqrt(x), 1.989)
# B = 1
# B = 1.9

# Δ is the total change in instantaneous frequency.
Δ = 2 * B / sqrt(4 - B^2)

# --------------------- #
#  P H A S E   P L O T  #
# --------------------- #

function Φ(t)
	α = t_i * sqrt(Δ^2 + 4)/(2 * Δ)
	(α - sqrt(α^2 - (t - t_i/2)^2))/Δ
end

s(t; fc = 0) = exp(im*2π*(fc * t + Φ(t)*BW))

t = range(0, t_i, step = inv(fs))

if enable_phase_plot
	plot(t, Φ.(t))
end

# ----------------------------- #
#  N O R M   F R E Q   P L O T  #
# ----------------------------- #

dΦ_dt = map(x -> only(gradient(Φ, x)), t)

if enable_norm_freq_plot
	plot(
		t, dΦ_dt,
		ticks = :native,
	)
end

# ------------------- #
#  F R E Q   P L O T  #
# ------------------- #

signal(t) = s(t, fc = 0)

f_i = map(x -> only(gradient.(τ -> angle(signal(τ))/2π, x)), t)

if enable_freq_plot
	plot(
		t, f_i,
		ticks = :native,
	)
end

# ----------------------- #
#  S I G N A L   P L O T  #
# ----------------------- #
#
# plot(
# 	plot(t, real.(signal.(t))),
# 	plot(t, imag.(signal.(t))),
# 	layout = grid(2, 1),
# 	ticks = :native,
# )

# ------------------------- #
#  A U T O C O R   P L O T  #
# ------------------------- #

t_acf = vcat(reverse(-t[1:end-1]), t)
acf = conv(signal.(t), reverse(conj.(signal.(t))))
acf_n = acf./maximum(abs.(acf))
acf_dB = 20*log10.(abs.(acf_n))

if enable_autocorr_plot
	plot(
		t_acf, acf_dB,
		ticks = :native,
	)
end

# ------------------- #
#  S I D E L O B E S  #
# ------------------- #

# Concept code for finding peak sidelobe level (PSL) and integrated sidelobe level (ISL).

using Peaks

idx_pk = argmax(acf_dB)
idx_nulls = argminima(acf_dB)
idx_left = idx_nulls[findlast(i -> i < idx_pk, idx_nulls)]
idx_right = idx_nulls[findfirst(i -> i > idx_pk, idx_nulls)]

# Also interesting option, but unfortunately no "prev" version of this function
findnextminima(acf_dB, idx_pk)

acf_peak = vcat(acf_n[idx_left:idx_right])
acf_sidelobes = vcat(acf_n[1:idx_left], acf_n[idx_right:end])

plot(20*log10.(abs.(acf_peak)))
plot(20*log10.(abs.(acf_sidelobes)))
PSL_dB = 20*log10.(maximum(abs.(acf_sidelobes)))
ISL_dB = 20*log10.(mean(abs.(acf_sidelobes)))

# Display the plot.
display(fig)

# ------- #
#  E O F  #
# ------- #
