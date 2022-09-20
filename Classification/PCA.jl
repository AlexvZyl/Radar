# Pcinciple component analysis to see which of the pixels contain the most data.

# Modules.
include("Directories.jl")
include("Utilities.jl")
include("../Utilities/MakieGL/PlotUtilities.jl")
include("DopplerMap.jl")
using MultivariateStats

# Get directories.
folder = "Test"
map_dir, cluster_dir, frames_dir, labels_dir, features_dir, extracted_targets_dir = get_directories(folder)
files = get_all_files(features_dir, true)

# Get the amount of features.
feature_count = length(load(files[1])["Feature Vector"])

# Load the features from the files and put them in a matrix.
# (Each column is an observation)
observation_matrix = Matrix{Float64}(undef, feature_count, 0)
for file in files
    global observation_matrix
    feature_vector = load(file)["Feature Vector"]
    observation_matrix = hcat(observation_matrix, feature_vector)
end

# Make each file a different target for testing.
labels = Vector(1:1:length(files))

pca_result = fit(PCA, observation_matrix, maxoutdim = 10)
display(pca_result)