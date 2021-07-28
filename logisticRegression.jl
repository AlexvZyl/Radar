using Flux
using DataFrames
using CSV

# Import data as dataframe
data = DataFrame(CSV.File("data/banking.csv"))

# Print Unique columns
print(unique(data.education))
# Replace values to make learning easier
println(data.education)


# Rename columns
# col_names = ["Pregnant", "Glucose", "BP", "Skin", "Insulin", "BMI", "Pedigree", "Age", "Label"]
# rename!(data, col_names)