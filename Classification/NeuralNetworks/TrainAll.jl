include("Trainer.jl")

persons = [ 1 ]
frames = [ 1,3,5,7,10,15,20 ]
models = [ LeNet5, AlexNet, LeNet5Temporal ]
batchsize = 10
train_test_split = 0.7
epochs=1000
timeout=50

# LeNet5.
LeNet5_weight = 0
LeNet5_learning_rate=5e-5

# AlexNet.
AlexNet_weight = 2.5e-3
AlexNet_learning_rate=5e-5
dropout = 0.15

# LeNet5.
LeNet5Temporal_weight = 0
LeNet5Temporal_learning_rate=3e-4
# LeNet5Temporal_learning_rate=5e-5

# Testing.
persons = [ 1 ]

# Run all itertions of the models.
for p in persons
    for f in frames
        for m in models
            frames_folder = string(f, "-Frames")
            if m == AlexNet
                train(m, split=train_test_split, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=AlexNet_weight, η=AlexNet_learning_rate, dropout=dropout)
            elseif m == LeNet5
                train(m, split=train_test_split, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=LeNet5_weight, η=LeNet5_learning_rate, dropout=dropout)
            elseif m == LeNet5Temporal
                train(m, split=train_test_split, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=LeNet5Temporal_weight, η=LeNet5Temporal_learning_rate, dropout=dropout)
            else
                # Train tree?
            end
        end
    end
end
