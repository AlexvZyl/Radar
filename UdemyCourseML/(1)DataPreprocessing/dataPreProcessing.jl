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
using TableView

# Math and ML
using Statistics
using Flux

# Find current directory.
currDir = pwd();
clearconsole()

#*=======================================================================================================
#* Main
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\(1)DataPreprocessing\\data.csv");
df = DataFrame(CSV.File.(filePath))

# Define variables.
featX = df[:, 1:end-1]
featY = df.Purchased;

# Find averages to replace missing values.
featX.Salary = coalesce.(featX.Salary, mean(skipmissing(featX.Salary)))
featX.Age = coalesce.(featX.Age, mean(skipmissing(featX.Age)))

# Encode Country data with one hot encoding.
onehotCountries = transpose(Flux.onehotbatch(featX.Country, unique(featX.Country)))

# Replace Country column with Onehot matrix
select!(df, :Salary =>  => :OneHot)

#*=======================================================================================================
#* EOF
#*=======================================================================================================
