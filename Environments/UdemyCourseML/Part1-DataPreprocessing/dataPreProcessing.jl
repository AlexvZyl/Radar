# Preprocessing section of the course.

#*=======================================================================================================
#* Initialising
#*=======================================================================================================

# Clear the console.
clearconsole();

# Import packages and functions.
using PreProcessing

#*=======================================================================================================
#* Script.
#*=======================================================================================================

# Create dataframe.
df = PreProcessing.dataframeFromFile("/UdemyCourseML/Part1-DataPreprocessing/data.csv")

# Replace missing values.
PreProcessing.replaceMissing!(df)

# Encode Country data with one hot encoding.
PreProcessing.oneHotEncoding!(df, 1)

# Train test split.
trainX, trainY, testX, testY = PreProcessing.trainTestSplit(df, 3)

# Apply feature scaling.
PreProcessing.featureScaling!(trainX)
PreProcessing.featureScaling!(testX)

#*=======================================================================================================
println("[END OF SCRIPT]")
#*=======================================================================================================
#* EOF
#*=======================================================================================================
