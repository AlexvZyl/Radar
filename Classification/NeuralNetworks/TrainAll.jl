include("Trainer.jl")

persons = [ 2 ]
frames = [ 1,3,5,7,10,15,20 ]
models = [ LeNet5, AlexNet, LeNet5StandardTemporal, LeNet5Temporal ]
batchsize = 10
train_ratio = 0.7
val_ratio = 0.2
test_ratio = 0.1
epochs=1000
timeout=75

# LeNet5.
LeNet5_weight = 0
LeNet5_learning_rate=5e-5

# AlexNet.
AlexNet_weight = 2.5e-3
AlexNet_learning_rate=5e-5
dropout = 0.15

# LeNet5 Standard Temporal.
LeNet5StandardTemporal_weight = 0
LeNet5StandardTemporal_learning_rate=3e-4

# LeNet5 Temporal.
LeNet5Temporal_weight = 0
LeNet5Temporal_learning_rate=3e-4

# Testing.
# persons = [ 2 ]
# frames = [ 1 ]
# models = [ LeNet5 ]

# LeNet5 Standard Temporal for 2 persons.
LeNet5StandardTemporal_weight = 0
LeNet5StandardTemporal_learning_rate=7e-4

# Testing.
persons = [ 2 ] 
frames = [ 5 ]
models = [ LeNet5 ]

# Run all itertions of the models.
for p in persons
    for f in frames
        for m in models
            frames_folder = string(f, "-Frames")
            if m == AlexNet
                train(m, train_ratio=train_ratio, val_ratio=val_ratio, test_ratio=test_ratio, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=AlexNet_weight, η=AlexNet_learning_rate, dropout=dropout)
            elseif m == LeNet5
                train(m, train_ratio=train_ratio, val_ratio=val_ratio, test_ratio=test_ratio, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=LeNet5_weight, η=LeNet5_learning_rate, dropout=dropout)
            elseif m == LeNet5Temporal
                train(m, train_ratio=train_ratio, val_ratio=val_ratio, test_ratio=test_ratio, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=LeNet5Temporal_weight, η=LeNet5Temporal_learning_rate, dropout=dropout)
            elseif m == LeNet5StandardTemporal
                train(m, train_ratio=train_ratio, val_ratio=val_ratio, test_ratio=test_ratio, batchsize=batchsize, epochs=epochs, persons=p, frames_folder=frames_folder, timeout=timeout, λ=LeNet5StandardTemporal_weight, η=LeNet5StandardTemporal_learning_rate, dropout=dropout)
            end
        end
    end
end
