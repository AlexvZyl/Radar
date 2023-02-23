include("Trainer.jl")

# Run the training script.
split = 0.75
batchsize = floor(Int64, 100 * (1 - split))
train(AlexNet, batchsize = 37, split = split, epochs = 100, checktime = 1, infotime = 1, frames_folder = "1-Frames")
