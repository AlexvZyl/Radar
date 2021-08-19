# Setup.
clearconsole()
using Flux

# Model.
func(x) = 4x + 2

# Data.
x_train, x_test = hcat(0:5...), hcat(6:10...)
y_train, y_test = func.(x_train), func.(x_test)

model = Dense(1,1)

# End.
println()
println("[EOF]")
# EOF.
