include("Trainer.jl")

persons = [ 1,2 ]
temporal = [ false,true ]
frames = [ 1,3,7,10,15,20,25,30 ]
models = [ LeNet5Adapted, AlexNet ]
batchsize = 8
split = 0.7
epochs=10
timeout=100

# Run all itertions of the testing.
for p in persons
    for f in frames
        for m in models
            frames_folder = string(f, "-Frames")
            if m == AlexNet
                train(m, split=split, batchsize = batchsize, epochs=epochs, temporal=false, persons=p, frames_folder = frames_folder, timeout=timeout)
                break
            end
            for t in temporal
                train(m, split=split, batchsize = batchsize, epochs=epochs, temporal=t, persons=p, frames_folder = frames_folder, timeout=timeout)
            end
        end
    end
end
