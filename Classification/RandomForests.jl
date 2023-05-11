using MLJ
using MLJModels
using MLJScikitLearnInterface
using MLJFlux
using Flux
RandomForestClassifier = MLJModels.@load RandomForestClassifier pkg=MLJScikitLearnInterface

include("NeuralNetworks/NetworkUtils.jl")

function random_forests(args::Args)
    model = RandomForestClassifier()
    train_x, train_y, test_x, test_y, labels = get_data_loaders(args)
end

args = Args(tree=true, persons=1, split=0.7, batchsize=8, epochs=1000)
random_forests(args)
