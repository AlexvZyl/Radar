# Principle component analysis to see which of the pixels contain the most data.

# Load the features as an observation matrix.
function load_observation_matrix(folder::String)

    features_dir = get_directories(folder)[5]
    files = get_all_files(features_dir, true)
    
    # Get the amount of features.
    feature_count = length(load(files[1])["Feature Vector"])
    
    # Load the features from the files and put them in a matrix.
    # (Each column is an observation)
    observation_matrix = Matrix{Float64}(undef, feature_count, 0)
    for file in files
        feature_vector = load(file)["Feature Vector"]
        observation_matrix = hcat(observation_matrix, feature_vector)
    end

    return observation_matrix

end

# Print the PCA result with a nice table.
import Base.print
using MultivariateStats
function Base.print(pca_result::PCA)

    principle_values = principalvars(pca_result)
    total_variance = var(pca_result)
    
    # Display the principle values.
    println("\n---------------------------------------------------------------------------------")
    println("|   Component\t|  \t    Eigen Value \t |      Variance Explained      |")
    println("---------------------------------------------------------------------------------")
    for (i, pval) in enumerate(principle_values)
        print("|      PC", i, "\t|       ")
        print(pval)
        print(" \t |     ")
        println(pval / total_variance, "  \t|")
    end
    println("---------------------------------------------------------------------------------")

end

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

# Load the matrices.
observation_matrix_walking_away     = load_observation_matrix("WalkingAway")
observation_matrix_walking_towards  = load_observation_matrix("WalkingTowards")
observation_matrix = hcat(observation_matrix_walking_towards, observation_matrix_walking_away)

# Assign labels.
# Should they be numbers?  Unsure.
labels_walking_away     = [ "WalkingAway" for i in 1:Base.size(observation_matrix_walking_away)[2] ]
labels_walking_towards  = [ "WalkingTowards" for i in 1:Base.size(observation_matrix_walking_towards)[2] ]
labels = vcat(labels_walking_away, labels_walking_towards)

# PCA.
# pca_result = fit(PCA, observation_matrix, maxoutdim = 10)
# print(pca_result)

# LDA.
lda_result = fit(MulticlassLDA, observation_matrix, labels; outdim=3)
new_samples_space = predict(lda_result, observation_matrix)
display(new_samples_space)
plot(new_samples_space, [ "WalkingAway", "WalkingTowards" ], [ length(labels_walking_away), length(labels_walking_towards) ])
