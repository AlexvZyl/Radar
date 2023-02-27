include("Trainer.jl")

# Run the training script.
model = LeNet5
batchsize = 20
train(model, batchsize = batchsize, split = split, epochs = 10000, checktime = 100, infotime = 1, frames_folder = "1-Frames")
