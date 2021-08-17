# Preprocessing section of the course.

#*=======================================================================================================
#* Initialising
#*=======================================================================================================

# Find current directory.
 currDir = pwd();
# Clear the console.
clearconsole();
# Import packages and functions.
include(string(currDir, "/Utilities/tools.jl"))

#*=======================================================================================================
#* Script.
#*=======================================================================================================

# Create dataframe.
df = dataframeFromFile("/UdemyCourseML/Part1-DataPreprocessing/data.csv")

# Replace missing values.
replaceMissing!(df)

# Encode Country data with one hot encoding.
oneHotEncoding!(df, 1)

# Train test split.
trainX, trainY, testX, testY = trainTestSplit(df, 3)

# Apply feature scaling.
featureScaling!(trainX)
featureScaling!(testX)

#*=======================================================================================================
println("[END OF SCRIPT]")
#*=======================================================================================================
#* EOF
#*=======================================================================================================
