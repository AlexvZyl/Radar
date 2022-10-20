include("Trainer.jl")

# Run the training script.
train(LeNet5, batchsize = 20, split = 0.55, epochs = 10000, checktime = 100, infotime = 100)
