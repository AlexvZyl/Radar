# Setup.
clearconsole()
using Flux
using Plots

display(plot(σ, -5, 5))

model =  Dense(2,1,σ)

x = rand(2)

display(methods(Flux.mse))

model(x)


# This course if out of date.
