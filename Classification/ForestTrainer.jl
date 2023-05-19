include("RandomForests.jl")

persons = [ 1, 2 ]
frames = [ 1,3,5,7,10,15,20 ]
tree_epochs = 2500
train_test_split = 0.7

for p in persons
    for f in frames
        frames_folder = string(f, "-Frames")
        args = Args(tree=true, persons=p, split=train_test_split, frames_folder=frames_folder, tree_epochs=tree_epochs)
        train_random_forests(args)
    end
end
