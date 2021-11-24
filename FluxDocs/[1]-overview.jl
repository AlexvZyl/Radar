# Setup.
clearconsole()
using Flux
using Flux: train!

# Model that needs to be predicted.
actualModel(x) = 4x + 2

# Data.
trainData, testData = hcat(0:5...), hcat(6:10...)
trainData, testData = [trainData, actualModel.(trainData)] , [testData, actualModel.(testData)]
println("Train Data: ", trainData)
println("Test Data: ", testData)

# Create the basic model using a dense layer.
predictModel = Dense(1,1)

# Implement loss function.
loss(x,y) = Flux.Losses.mse(predictModel(x), y)
# Check loss value.
lossValue = loss(trainData[1], trainData[2])
println()
println("Loss before training: ", lossValue)

# Train the model using data and a loss model.
opt = Descent() # Classic gradient descent.
parameters = params(predictModel) # Collect the paramters.
data = [(trainData[1], trainData[2])]
train!(loss, parameters, data, opt)

# Iterate process.
for epoch in 1:10000
         train!(loss, parameters, data, opt)
end # Loop.

# Check loss value.
lossValue = loss(trainData[1], trainData[2])
println("Loss after training: ", lossValue)

# Predict.
prediction = predictModel(trainData[1])
println()
println("[TRAIN] Actual Data: ", trainData[2])
println("[TRAIN] Predict Data: ", prediction)

# Test.
prediction = predictModel(testData[1])
println()
println("[TEST] Actual Data: ", testData[2])
println("[TEST] Predict Data: ", prediction)

# End prints.
println()
println("[EOS]")
# EOF.
