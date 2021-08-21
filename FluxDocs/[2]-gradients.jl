# Setup.
clearconsole()
using Flux

#=============================================================================#
# Gradients.
#=============================================================================#

# Taking Gradients.
f(x) = 3x^2 + 2x + 1 # Function.
df(x) = gradient(f, x)[1] # Gradient of function.
df2(x) = gradient(df, x)[1] # Second derivative of function.

# Multiple variables.
f(x,y) = sum((x.-y).^2)
gradient(f, [2,1], [1,0])
x = [2,1,2]
y = [1,5,6]
gs = gradient(params(x,y)) do # Passes what is in the block as the fist argument.
    f(x,y)
end # Function.




#=============================================================================#
# Gradients.
#=============================================================================#

# End prints.
println()
println("[EOS]")
# EOF.
