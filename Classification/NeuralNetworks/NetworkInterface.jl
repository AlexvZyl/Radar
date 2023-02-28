include("Trainer.jl")

# Run the training script.
model = LeNet5Adapted
batchsize = 16
train(model, batchsize = batchsize, epochs = 10000, checktime = 100, infotime = 1, frames_folder = "10-Frames")
