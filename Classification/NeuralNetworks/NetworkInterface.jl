include("Trainer.jl")

# Run the training script.
model = LeNet5Adapted
batchsize = 8
train(model, batchsize = batchsize, epochs = 10000, checktime = 100, infotime = 1, temporal=false, persons=2, frames_folder = "5-Frames")
