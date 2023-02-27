include("Trainer.jl")

# Run the training script.
model = LeNet5Adapted
split = 0.8
batchsize = floor(Int64, 100 * (1 - split))
train(model, batchsize = batchsize, split = split, epochs = 10000, checktime = 100, infotime = 1, frames_folder = "1-Frames")
