include("RandomForests.jl")

persons = [ 1 ]
frames = [ 1, 10 ]
tree_epochs = 10000
train_test_split = 0.7

for p in persons
    for f in frames
        frames_folder = string(f, "-Frames")
        args = Args(tree=true, persons=p, split=train_test_split, frames_folder=frames_folder, tree_epochs=tree_epochs)
        train_random_forests(args)
    end
end
