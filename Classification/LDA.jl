# Principle component analysis to see which of the pixels contain the most data.
using MultivariateStats
using MLUtils

# Modules.
include("../Utilities/MakieGL/PlotUtilities.jl")
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")
using Random

# Load the matrices.
observation_matrix_walking_towards  = load_observation_matrix("WalkingTowards")
observation_matrix_walking_away     = load_observation_matrix("WalkingAway")
observation_matrix = hcat(observation_matrix_walking_towards, observation_matrix_walking_away)

# Assign labels.
labels_walking_towards  = [ "WalkingTowards" for i in 1:Base.size(observation_matrix_walking_towards)[2] ]
labels_walking_away     = [ "WalkingAway" for i in 1:Base.size(observation_matrix_walking_away)[2] ]
labels                  = permutedims(vcat(labels_walking_towards, labels_walking_away))

# Add the labels to the observation matrices so that we can easily split it.
# Make the first row the label, and the rest are the features.
observation_matrix_labeled = vcat(labels, observation_matrix)
# Shuffle the data order.
rng = MersenneTwister(1234)
observation_matrix_labeled = observation_matrix_labeled[:, shuffle(rng, Vector(1:Base.size(observation_matrix_labeled)[2]))]
train, test = splitobs(observation_matrix_labeled, at = 0.7)

# Train the model.
lda_model = fit(MulticlassLDA, Matrix{Float64}(train[2:end, :]), Vector{String}(train[1, :]), outdim = 10)
# Convert test space to lda space.
test_result = predict(lda_model, Matrix{Float64}(test[2:end, :]))
display(vcat(permutedims(test[1, :]), test_result))
