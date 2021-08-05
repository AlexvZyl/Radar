# Preprocessing section of the course.

#*=======================================================================================================
#* Initialising
#*=======================================================================================================

# Find current directory.
currDir = pwd();
# Clear the console.
clearconsole();
# Import packages and functions.
include(string(currDir, "\\Utilities\\imports.jl"))

#*=======================================================================================================
#* Script.
#*=======================================================================================================

# Create dataframe.
filePath = string(currDir, "\\UdemyCourseML\\Part1-DataPreprocessing\\data.csv");
df = DataFrame(CSV.File.(filePath))

# Find averages to replace missing values.
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
#* Functions.
#*=======================================================================================================

# Dataframe feature scaling.
# Dataframe should only contain Bools and numbers.
function featureScaling!(data::DataFrame, type::String)

    # types = ["Std", "Nrm"]
    if type == "Std"
        # Loop through the columns of the datafram
        for col in range(1, stop = ncol(data))
            # Check if column is a number.
            if eltype(data[!, col]) != Bool
                colMean = mean(data[:, col])
                colStd = std(data[:, col])
                # Apply to rows.
                for row in range(1, stop = nrows(data))
                    data[row, col] = (data[row, col] - colMean) / colStd
                end # loop
            end # if
        end # loop

    elseif type == "Nrm"
        # Loop through the columns of the datafram
        for col in range(1, stop = ncol(data))
            # Check if column is a number.
            if eltype(data[!, col]) != Bool
                colMax = maximum(data[:, col])
                colMin = minimum(data[:, col])
                # Apply to rows.
                for row in range(1, stop = nrows(data))
                    data[row, col] = (data[row, col] - colMin) / (colMax - colMin)
                end # loop
            end # if
        end # loop
    end # if

end # function

#*=======================================================================================================
println("[INFO] Done.")
#*=======================================================================================================
#* EOF
#*=======================================================================================================
