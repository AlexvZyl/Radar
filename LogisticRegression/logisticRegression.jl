using Flux
using DataFrames
using CSV
using Plots

# Read CSV file
Data = DataFrame(CSV.File("banking.csv"))
println(DataFrames.size(Data))

# Replace some of the names to make classification easier
println(DataFrames.unique(Data.education))
DataFrames.replace!(Data.education, "basic.4y" => "basic")
DataFrames.replace!(Data.education, "basic.6y" => "basic")
DataFrames.replace!(Data.education, "basic.9y" => "basic")
println(DataFrames.unique(Data.education))

# Plot data
plotlyjs() # Enable backend
x = unique(Data.y)
Totals = [0,0]
for val in Data.y
    if val == 0 
        global Totals[1] += 1
    else 
        global Totals[2] += 1
    end
end
println(x, Totals)
histogram(x, Totals)
xaxis!("y")



# FeatureNames = []
# FeatureData = select(Data, FeatureNames)

# # Write to CSV file
# CSV.write("OutputFile.csv", FeatureData)