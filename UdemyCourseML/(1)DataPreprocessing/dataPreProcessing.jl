# Preprocessing section of the course.

#*=======================================================================================================
#* Initialising
#*=======================================================================================================

# Drawing/Visualization packages.
using Plots

# Data.
using RDatasets
using DataFrames
using CSV
using Statistics
using TableView

# Find current directory.
currDir = pwd();

#*=======================================================================================================
#* Main
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\(1)DataPreprocessing\\data.csv");
df = DataFrame(CSV.File.(filePath))
println(df)

# Define variables.
featX = df[:,1:end-1]
featY = df.Purchased;

# Find averages to replace missing values.
salaryAvg = mean(skipmissing(featX.Salary))
ageAvg =  mean(skipmissing(featX.Age))

# Replace missing values.
featX.Salary =  coalesce.(featX.Salary, salaryAvg)
featX.Age =  coalesce.(featX.Salary, ageAvg)
println(featX)
println(featY)
showtable(df)

#*=======================================================================================================
#* EOF
#*=======================================================================================================
