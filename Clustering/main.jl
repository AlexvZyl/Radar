using Clustering

# Random dataset.
data = rand(5, 1000)

# Clustering.
clusters = 2 
result = kmeans(data, clusters; maxiter=200, display=:iter)

@assert nclusters(result) == clusters

println("Assignemnts: ", assignments(result))
println("Counts: ", counts(result))
println("Centers: ", result.centers)
