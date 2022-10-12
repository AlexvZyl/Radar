# Principle component analysis to see which of the pixels contain the most data.

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

# Modules.
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
pca_result = fit(PCA, observation_matrix, maxoutdim = 10)
print(pca_result)
