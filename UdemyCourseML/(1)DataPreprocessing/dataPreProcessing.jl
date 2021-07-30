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

# Find currnent directory.
currDir = pwd();

#*=======================================================================================================
#* Main
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\(1)DataPreprocessing\\Data.csv");
df = DataFrame(File.(filePath))
println(df)

# Define variables.
featX = df[:,1:end-1]
featY = df.Purchased;

# Find averages to replace missing values.
salaryAvg = mean(skipmissing(featX.Salary))
ageAvg =  mean(skipmissing(featX.Age))

# Replace missing values.
convert.(Float64, skipmissing(featX.Salary))  # Change variable types.
println(eltype(featX.Salary))
replace!(featX.Salary, missing=>salaryAvg)  # Replace values.
