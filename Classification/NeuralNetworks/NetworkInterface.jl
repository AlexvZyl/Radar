include("Trainer.jl")

# Run the training script.
split = 0.75
batchsize = floor(Int64, 100 * (1 - split))
train(LeNet5, batchsize = 37, split = split, epochs = 10000, checktime = 100, infotime = 100, frames_folder = "1-Frames")
