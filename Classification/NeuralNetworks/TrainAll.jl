include("Trainer.jl")

persons = [ 1 ]
temporal = [ false,true ]
frames = [ 1,3,5,7,10,15,20 ]
models = [ LeNet5Adapted, AlexNet ]
batchsize = 5
train_test_split = 0.7
epochs=1000
timeout=50

# LeNet5.
LeNet5_learning_rate=0.0005

# AlexNet.
AlexNet_weight = 2.5e-3
AlexNet_learning_rate=5e-5
dropout = 0.15

# Testing.
models = [ AlexNet ]
frames = [ 20 ]
persons = [ 1 ]
temporal  = [ false ]

# Run all itertions of the models.
for p in persons
    for f in frames
        for m in models
            frames_folder = string(f, "-Frames")
            if m == AlexNet
                train(m, split=train_test_split, batchsize=batchsize, epochs=epochs, temporal=false, persons=p, frames_folder=frames_folder, timeout=timeout, λ=AlexNet_weight, η=AlexNet_learning_rate, dropout=dropout)
                break
            end
            for t in temporal
                train(m, split=train_test_split, batchsize=batchsize, epochs=epochs, temporal=t, persons=p, frames_folder=frames_folder, timeout=timeout, λ=0, η=LeNet5_learning_rate, dropout=dropout)
            end
        end
    end
end
