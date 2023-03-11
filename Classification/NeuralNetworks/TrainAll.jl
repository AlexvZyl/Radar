include("Trainer.jl")

persons = [ 1,2 ]
temporal = [ false,true ]
frames = [ 1,3,7,10,15,20,25,30 ]
models = []
model = LeNet5Adapted
batchsize = 8

# Run all itertions of the testing.
for p in persons
    for t in temporal
        for f in frames
            frames_folder = string(f, "-Frames")
            train(model, split = 0.7, batchsize = batchsize, epochs = 10, checktime = 100, infotime = 1, temporal=t, persons=p, frames_folder = frames_folder)
        end
    end
end
