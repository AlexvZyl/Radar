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

# Find current directory.
currDir = pwd();

#*=======================================================================================================
#* Main
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\(1)DataPreprocessing\\Data.csv");
println(filePath)
df = DataFrame(File.(filePath))
println(df)

# Define variables.
featX = df[:,1:end-1]
featY = df.Purchased;

# Find averages to replace missing values.
salaryAvg = mean(skipmissing(featX.Salary))
ageAvg =  mean(skipmissing(featX.Age))

# Replace missing values.
toReplace =  convert.(Float64, skipmissing(featX.Sala))  # Change variable types.
# replace!(featX.Salary, missing=>salaryAvg)  # Replace values.

#*=======================================================================================================
#* EOF
#*=======================================================================================================