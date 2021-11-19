using GLMakie
using FFTW
set_theme!(theme_dark())

nSamples = 100001
bandwidth = 2000
amplitude = 1
samplingFreq = 4000

wave = Array{Complex}(undef, nSamples)
gradient = bandwidth / (nSamples - 1)
index = 1

# Generate samples array.
samples = floor(-(nSamples-1)/2):ceil(((nSamples-1)/2)
)# Generate waveform.
for n in samples
	FREQ = ((gradient * (index-1)) - (bandwidth/2))/samplingFreq
	wave[index] = exp(n * -2 * pi * FREQ * im)
 	global index += 1
end # For.

# ================== #
#   Draw the plot.   #
# ================== #

# Display data.
f = Figure()
# 2D Plotting the blocks.
ax = Axis(f[1, 1], xlabel = "Sample", ylabel = "Value", title = "Transmission Signal")
# xlims!(ax, 0, 8200)
# ylims!(ax, -18000, 18000)
plt1 = lines!(real(wave), color = :blue, markersize = 5)
plt1 = scatter!(real(wave), color = :blue, markersize = 5)
plt2 = lines!(imag(wave), color = :orange, markersize = 5)
plt2 = scatter!(imag(wave), color = :orange, markersize = 5)
legend = Legend
(
    f[1,2],
    [plt1, plt2],
    ["I Channel", "Q Channel"]
)
# Draw the FFT.
FFT = abs.(fft(real(wave) + imag(wave)*im)) / nSamples
logFFT = 20* log10.(FFT/maximum(FFT))
samplesNormalized = 0:1/(nSamples-1):1
Axis(f[1, 2], xlabel = "k", ylabel = "Magnitude (dB)", title = "FFT")
lines!(samplesNormalized, logFFT, color = :blue, marksersize = 5)
scatter!(samplesNormalized, logFFT, color = :blue, markersize = 5)
# Display the figure.
display(f)
