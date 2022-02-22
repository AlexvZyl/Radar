### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 77cdab18-2a75-11ec-3e5c-7b60dd7c7fb3
begin
	using DSP
	using Plots
	using PlutoUI
	using StatsBase
	using Zygote
end

# ╔═╡ 129c1d3c-43bb-422d-aa03-fbcae0802a55
using Peaks

# ╔═╡ 407080f1-753d-4d00-8ad6-9ac4844371ac
md"""
# NLFM
## Explore the non-linear frequency modulation formulation from Lesnik2009
"""

# ╔═╡ e4012e26-d2c6-4278-87a2-74a0c828124e


# ╔═╡ ff47dc2c-7cc0-436e-9308-e146173bff4e
md"Specify the duration ``t_i`` and bandwidth ``BW`` of the chirp"

# ╔═╡ 0f934d3b-b28e-4db9-9450-b04e3426443a
begin
	# t_i = 3.33e-6
	t_i = 50e-6
	# BW = 5.5e6
	BW = 50e6
end

# ╔═╡ 54e9f0d5-a92e-4289-9e22-14abed95eb58
fs = 110e6
# fs = 50e6

# ╔═╡ cae2e53e-b7d9-48a5-8e85-b7682b09704f
md"""
B changes the \"intensity\" of the non-linearty of the chirp. The valid range is 0 < B < 2, with B closer to 0 giving close to a linear chirp and B close to 2 giving very rapid chirp rate near the start and end of the pulse. The useful or interesting range is 1 < B < 1.99, with B close to 1 giving a very subtle non-linear chirp and 
"""

# ╔═╡ 8abfae45-cbed-4832-90c5-456b12eb6269
md"""
Specify B via a square root function, i.e. ``B = \sqrt{x}``, to get finer increments near 2 than near 1.

x = $(@bind x Slider(range(1, 4, step = 0.05), default = 3.6, show_value = true))
"""

# ╔═╡ 20ba7fab-3524-4ca5-a86c-8991417a35eb
B = min(sqrt(x), 1.989)
# B = 1
# B = 1.9

# ╔═╡ 1af4b49e-2edb-4199-9460-48b51a4e93ee
md"""
Δ is the total change in instantaneous frequency
"""

# ╔═╡ b110be72-307f-4c13-be3c-96024239dbda
Δ = 2 * B / sqrt(4 - B^2)

# ╔═╡ e5e109ef-9054-40a7-a4f8-b9b349a3d1b5
t_i * sqrt(Δ^2 + 4)/(2 * Δ)

# ╔═╡ d0ced2dc-5db2-467c-b745-829cc563f2fc
function Φ(t)
	α = t_i * sqrt(Δ^2 + 4)/(2 * Δ)
	(α - sqrt(α^2 - (t - t_i/2)^2))/Δ
	   # α = t .- ( t_i/2 )
   # β = ( t_i^2 * (Δ^2+4) ) / ( 4*Δ^2 )
   # γ = ( t .- t_i/2 ) .^ 2
   # α ./ sqrt.(β .- γ)
end

# ╔═╡ 4ebf026b-5867-4c2a-9130-4b283e22f824
s(t; fc = 0) = exp(im*2π*(fc * t + Φ(t)*BW))
# s(t; fc = 0) = exp(im*2π*Φ(t)/fs)

# ╔═╡ a540da18-4ceb-424d-bdfd-7cb58256c328
t = range(0, t_i, step = inv(fs))

# ╔═╡ 7544940d-8cae-4c16-aa5a-b3616d5c05a5
md"Enable phase plot $(@bind enable_phase_plot CheckBox(default = false))"

# ╔═╡ b9c3e253-9010-479c-95f5-b446837ba96d
enable_phase_plot && plot(t, Φ.(t))

# ╔═╡ cb800cdc-8fd2-48d3-b98c-d91c8caa4633
dΦ_dt = map(x -> only(gradient(Φ, x)), t)

# ╔═╡ d662d004-ef91-4dea-89d0-3232f181b789
md"Enable normalised instantaneous frequency plot $(@bind enable_norm_freq_plot CheckBox(default = false))"

# ╔═╡ db3dc970-2943-40c4-99ba-d68b91a52424
if enable_norm_freq_plot
	plot(
		t, dΦ_dt,
		ticks = :native,
	)
end

# ╔═╡ 8f06dea8-a170-4501-ace9-5a52d4a33e5f
signal(t) = s(t, fc = 0)

# ╔═╡ eaa40fc1-9988-4e22-b7c3-d0921b2af26b
f_i = map(x -> only(gradient.(τ -> angle(signal(τ))/2π, x)), t)

# ╔═╡ bab8bebe-db08-44d1-8988-b89cb67c87d8
md"Enable instantaneous frequency plot $(@bind enable_freq_plot CheckBox(default = false))"

# ╔═╡ 5f8f96ea-469a-45e8-9698-61144f98e63d
if enable_freq_plot
	plot(
		t, f_i,
		ticks = :native,
	)
end

# ╔═╡ 333a3fc4-d464-499c-bacf-003f66abc9ff
plot(
	plot(t, real.(signal.(t))),
	plot(t, imag.(signal.(t))),
	layout = grid(2, 1),
	ticks = :native,
)

# ╔═╡ e999e852-f48f-4035-956c-1ea656b4911d
begin
	t_acf = vcat(reverse(-t[1:end-1]), t)
	acf = conv(signal.(t), reverse(conj.(signal.(t))))
	acf_n = acf./maximum(abs.(acf))
	acf_dB = 20*log10.(abs.(acf_n))
end

# ╔═╡ 65521573-c6e4-499d-8ce7-212650a659ef
md"Enable autocorrelation plot $(@bind enable_autocorr_plot CheckBox(default = false))"

# ╔═╡ dd916ce2-c1d3-4bd0-8632-dd9cc3625e2c
if enable_autocorr_plot
	plot(
		t_acf, acf_dB,
		ticks = :native,
	)
end

# ╔═╡ cb72c609-0d09-45cd-9e63-1f1a530474e7
md"""
---
Concept code for finding peak sidelobe level (PSL) and integrated sidelobe level (ISL)
"""

# ╔═╡ c8cdf325-0593-4b3b-a0c8-fbd5dbf5179d
idx_pk = argmax(acf_dB)

# ╔═╡ 454d2ed5-e9ca-4b30-b3d9-c0049f4a9cee
idx_nulls = argminima(acf_dB)

# ╔═╡ bec0f416-c145-4951-9561-bc7170ae3a7f
idx_left = idx_nulls[findlast(i -> i < idx_pk, idx_nulls)]

# ╔═╡ f3a1c69d-09ca-48ca-902a-6fb35ffb75d7
idx_right = idx_nulls[findfirst(i -> i > idx_pk, idx_nulls)]

# ╔═╡ 94a3fea3-8fa5-456e-9c84-011a0f6e990e
# Also interesting option, but unfortunately no "prev" version of this function
findnextminima(acf_dB, idx_pk)

# ╔═╡ cd6c32be-eb78-4d89-ba4d-00083253eb78
begin
	acf_peak = vcat(acf_n[idx_left:idx_right])
	acf_sidelobes = vcat(acf_n[1:idx_left], acf_n[idx_right:end])
end

# ╔═╡ bdf988fc-c0ef-43bd-b43e-9ebdc30d6d87
plot(20*log10.(abs.(acf_peak)))

# ╔═╡ f6aebc85-4f65-4e0d-86b2-5a516cff47c5
plot(20*log10.(abs.(acf_sidelobes)))

# ╔═╡ 1f90f5b7-d13f-4ba3-bba9-2a0bee35d908
PSL_dB = 20*log10.(maximum(abs.(acf_sidelobes)))

# ╔═╡ be0c061e-f4db-43d7-88b9-b7d8f031f299
ISL_dB = 20*log10.(mean(abs.(acf_sidelobes)))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DSP = "717857b8-e6f2-59f4-9121-6e50c889abd2"
Peaks = "18e31ff7-3703-566c-8e60-38913d67486b"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
DSP = "~0.7.4"
Peaks = "~0.4.0"
Plots = "~1.25.4"
PlutoUI = "~0.7.27"
StatsBase = "~0.33.14"
Zygote = "~0.6.33"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
"""

# ╔═╡ Cell order:
# ╟─407080f1-753d-4d00-8ad6-9ac4844371ac
# ╠═e4012e26-d2c6-4278-87a2-74a0c828124e
# ╠═77cdab18-2a75-11ec-3e5c-7b60dd7c7fb3
# ╟─ff47dc2c-7cc0-436e-9308-e146173bff4e
# ╠═0f934d3b-b28e-4db9-9450-b04e3426443a
# ╠═54e9f0d5-a92e-4289-9e22-14abed95eb58
# ╟─cae2e53e-b7d9-48a5-8e85-b7682b09704f
# ╟─8abfae45-cbed-4832-90c5-456b12eb6269
# ╠═20ba7fab-3524-4ca5-a86c-8991417a35eb
# ╟─1af4b49e-2edb-4199-9460-48b51a4e93ee
# ╠═b110be72-307f-4c13-be3c-96024239dbda
# ╠═e5e109ef-9054-40a7-a4f8-b9b349a3d1b5
# ╠═d0ced2dc-5db2-467c-b745-829cc563f2fc
# ╠═4ebf026b-5867-4c2a-9130-4b283e22f824
# ╠═a540da18-4ceb-424d-bdfd-7cb58256c328
# ╟─7544940d-8cae-4c16-aa5a-b3616d5c05a5
# ╠═b9c3e253-9010-479c-95f5-b446837ba96d
# ╠═cb800cdc-8fd2-48d3-b98c-d91c8caa4633
# ╟─d662d004-ef91-4dea-89d0-3232f181b789
# ╠═db3dc970-2943-40c4-99ba-d68b91a52424
# ╠═8f06dea8-a170-4501-ace9-5a52d4a33e5f
# ╠═eaa40fc1-9988-4e22-b7c3-d0921b2af26b
# ╟─bab8bebe-db08-44d1-8988-b89cb67c87d8
# ╠═5f8f96ea-469a-45e8-9698-61144f98e63d
# ╠═333a3fc4-d464-499c-bacf-003f66abc9ff
# ╠═e999e852-f48f-4035-956c-1ea656b4911d
# ╟─65521573-c6e4-499d-8ce7-212650a659ef
# ╠═dd916ce2-c1d3-4bd0-8632-dd9cc3625e2c
# ╟─cb72c609-0d09-45cd-9e63-1f1a530474e7
# ╠═129c1d3c-43bb-422d-aa03-fbcae0802a55
# ╠═c8cdf325-0593-4b3b-a0c8-fbd5dbf5179d
# ╠═454d2ed5-e9ca-4b30-b3d9-c0049f4a9cee
# ╠═bec0f416-c145-4951-9561-bc7170ae3a7f
# ╠═f3a1c69d-09ca-48ca-902a-6fb35ffb75d7
# ╠═94a3fea3-8fa5-456e-9c84-011a0f6e990e
# ╠═cd6c32be-eb78-4d89-ba4d-00083253eb78
# ╠═bdf988fc-c0ef-43bd-b43e-9ebdc30d6d87
# ╠═f6aebc85-4f65-4e0d-86b2-5a516cff47c5
# ╠═1f90f5b7-d13f-4ba3-bba9-2a0bee35d908
# ╠═be0c061e-f4db-43d7-88b9-b7d8f031f299
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
