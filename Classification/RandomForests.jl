using MLJ
using MLJModels
using MLJScikitLearnInterface
using MLJFlux
using Flux
RandomForestClassifier = MLJModels.@load RandomForestClassifier pkg=MLJScikitLearnInterface

include("NeuralNetworks/NetworkUtils.jl")

function random_forests(args::Args)
    model = RandomForestClassifier()
    
end

random_forests(Args())
