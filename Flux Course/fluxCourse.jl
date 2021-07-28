using Flux
using Plots

plot(σ, -5, 5, label="\\sigma", xlabel ="x", ylabel="\\sigma\\(x\\)")

# Neural network
model = Dense(2, 1, σ)