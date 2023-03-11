include("Trainer.jl")

# Run the training script.
model = AlexNet
batchsize = 8
train(model, split = 0.7, batchsize = batchsize, epochs = 10000, checktime = 100, infotime = 1, temporal=false, persons=1, frames_folder = "5-Frames")
