# Principle component analysis to see which of the pixels contain the most data.

using MultivariateStats
using MLUtils

# Plot the LDA result.  Creates a new figure and axis.
include("../Utilities/MakieGL/PlotUtilities.jl")
function plot(transformed_observation_matrix::AbstractMatrix, labels::AbstractVector, labels_count::AbstractVector)

    # Setup.
    figure = Figure()
    axis = Axis3(figure[1,1], xlabel = "Feature 1", ylabel = "Feature 2", zlabel = "Feature 3")

    # Plot each class.
    total_points = 0
    for (i, label) in enumerate(labels)
        label_range = 1+total_points:1:labels_count[i]+total_points
        scatter!(
            transformed_observation_matrix[1, label_range],
            transformed_observation_matrix[2, label_range],
            transformed_observation_matrix[3, label_range],
            label = label
        )
        total_points += labels_count[i]
    end

    # Display the plot to the screen.
    display(figure)

end

# Modules.
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")

# Use splitobs for train/test splits.

# Load the matrices.
observation_matrix_walking_away     = load_observation_matrix("WalkingAway")
observation_matrix_walking_towards  = load_observation_matrix("WalkingTowards")
observation_matrix = hcat(observation_matrix_walking_towards, observation_matrix_walking_away)

# Assign labels.
labels_walking_away     = [ "WalkingAway" for i in 1:Base.size(observation_matrix_walking_away)[2] ]
labels_walking_towards  = [ "WalkingTowards" for i in 1:Base.size(observation_matrix_walking_towards)[2] ]
labels                  = vcat(labels_walking_away, labels_walking_towards)

# LDA with all of the data.
# lda_result = fit(MulticlassLDA, observation_matrix, labels; outdim=3)
# new_samples_space = predict(lda_result, observation_matrix)
# plot(new_samples_space, [ "WalkingAway", "WalkingTowards" ], [ length(labels_walking_away), length(labels_walking_towards) ])

# Remove some of the data for training so that we can test it.
observation_matrix_walking_away_reduced = random_delete(observation_matrix_walking_away)
observation_matrix_walking_towards_reduced = random_delete(observation_matrix_walking_towards)
observation_matrix_reduced = hcat(observation_matrix_walking_towards_reduced, observation_matrix_walking_away_reduced)

# Create labels.
labels_walking_away_reduced     = [ "WalkingAway" for _ in 1:Base.size(observation_matrix_walking_away_reduced)[2] ]
labels_walking_towards_reduced  = [ "WalkingTowards" for _ in 1:Base.size(observation_matrix_walking_towards_reduced)[2] ]
labels_reduced                  = vcat(labels_walking_away_reduced, labels_walking_towards_reduced)

# LDA on the reduced data.
lda_result_reduced = fit(MulticlassLDA, observation_matrix_reduced, labels_reduced, outdim=3)
results_reduced = predict(lda_result_reduced, observation_matrix)
plot(results_reduced, [ "WalkingAway", "WalkingTowards" ], [ length(labels_walking_away), length(labels_walking_towards) ])
