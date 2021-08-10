# Preprocessing section of the course.

#*=======================================================================================================
#* Initialising
#*=======================================================================================================

# Find current directory.
currDir = pwd();
# Clear the console.
clearconsole();
# Import packages and functions.
include(string(currDir, "\\Utilities\\tools.jl"))

#*=======================================================================================================
#* Script.
#*=======================================================================================================

# Create dataframe.
df = dataframeFromFile("\\UdemyCourseML\\Part1-DataPreprocessing\\data.csv")



# Find averages to replace missing values.
# replaceMissing!(df)
df.Salary = coalesce.(df.Salary, mean(skipmissing(df.Salary)))
df.Age = coalesce.(df.Age, mean(skipmissing(df.Age)))

# Encode Country data with one hot encoding.
onehot!(df, :Country, outnames = Symbol.(unique(df.Country)))
select!(df, (2:7))

# Shuffle the dataset.
df = df[shuffle(1:size(df, 1)), :]
# Train/Test split.
train, test = splitobs(df, at = 0.7)

# Define variables.
trainY, trainX = train.Purchased, select(train, Not(:Purchased))
testY, testX = test.Purchased, select(test, Not(:Purchased))

# Apply feature scaling.
featureScaling!(trainX, "Std")
featureScaling!(testX, "Std")

#*=======================================================================================================
println("[INFO] Done.")
#*=======================================================================================================
#* EOF
#*=======================================================================================================
