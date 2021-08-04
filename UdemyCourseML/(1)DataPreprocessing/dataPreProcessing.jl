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
# using TableView:pretty
using DataConvenience:onehot!
using MLDataUtils:splitobs
using StatsBase:standardize

# Math, Stats and ML.
using Flux
using MLJ

# Find current directory.
currDir = pwd();
# Clear the console.
# clearconsole()
# Console.clear()

#*=======================================================================================================
#* Main
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\(1)DataPreprocessing\\data.csv");
df = DataFrame(CSV.File.(filePath))
PrettyTables.pretty_table(df)

# Find averages to replace missing values.
df.Salary = coalesce.(df.Salary, mean(skipmissing(df.Salary)))
df.Age = coalesce.(df.Age, mean(skipmissing(df.Age)))

# Encode Country data with one hot encoding.
onehot!(df, :Country, outnames=Symbol.(unique(df.Country)))
select!(df, (2:7))

# Shuffle the dataset.
df = df[shuffle(1:size(df, 1)),:]
# Train/Test split.
train, test = splitobs(df, at=0.7)

# Define variables.
trainX, trainY = train.Purchased, select(train, Not(:Purchased))
testX, testY = test.Purchased, select(test, Not(:Purchased))

# Feature scaling.
# StatsBase.standardize()

println("[INFO] Done.")
#*=======================================================================================================
#* EOF
#*=======================================================================================================
