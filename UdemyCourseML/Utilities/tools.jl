
# This package is created to handle the imports of all of the packages and functions that
# are needed to do ML in julia.
# Seems like the environemnt of Julia is still a bit deurmekaar.

#*=======================================================================================================
#* Drawing and viewing.
#*=======================================================================================================

# Normal plotting.
using Plots
# Viewing dataframes.
using FloatingTableView

#*=======================================================================================================
#* Data handling.
#*=======================================================================================================

# Machine Learning.
using MLDataUtils
# using MLJ # Clashes with MLDataUtils.
using Flux

# GPU.
using CUDA

# Data.
using RDatasets
using DataFrames
using CSV
using DataConvenience
using StatsBase
using Random

#*=======================================================================================================
#* Import file from current directory.
#*=======================================================================================================

# Create a dataframe from the file in the given path and set if it is from
# the current directory or not.
function dataframeFromFile(path::String; fromDirectory::Bool=true, display::Bool=true)

    # If current directory should be taken.
    if fromDirectory
        # Current director.
        dir = pwd()
        # Create dataframe.
        df = DataFrame(CSV.File.(string(dir,path)))
    # Else do not take from current directory.
    else
        df = DataFrame(CSV.File.(string(dir,path)))
    end # If.

        # Print the dataframe.
    if display
        println("[PREPROCESSING] Dataframe created:")
        PrettyTables.pretty_table(df)
        println()
    end # if

    # Return the created dataframe.
    return df

end # Function.

#*=======================================================================================================
#* Feature scaling.
#*=======================================================================================================

# Dataframe feature scaling.
# Dataframe should only contain Bools and numbers.
function featureScaling!(df::DataFrame; type::String="Std", displayBool::Bool=true)

    # types = ["Std", "Nrm"]
    if type == "Std"
        # Loop through the columns of the datafram
        for col in range(1, stop = ncol(df))
            # Check if column is a number.
            if (eltype(df[!,col]) != String) && (eltype(df[!,col]) != Bool)
                colMean = mean(df[:, col])
                colStd = std(df[:, col])
                # Apply to rows.
                for row in range(1, stop = nrows(df))
                    df[row, col] = (df[row, col] - colMean) / colStd
                end # loop
            end # if
        end # loop

    elseif type == "Nrm"
        # Loop through the columns of the dataframe.
        for col in range(1, stop = ncol(df))
            # Check if column is a number.
            if (eltype(df[!,col]) != String) && (eltype(df[!,col]) != Bool)
                colMax = maximum(df[:, col])
                colMin = minimum(df[:, col])
                # Apply to rows.
                for row in range(1, stop = nrows(df))
                    df[row, col] = (df[row, col] - colMin) / (colMax - colMin)
                end # loop
            end # if
        end # loop
    end # if

    if displayBool
        println(string("[PREPROCESSING] Applied feature scaling (", type, "):" ))
        PrettyTables.pretty_table(df)
        println()
    end # If.

end # function

#*=======================================================================================================
#* Replace missing values.
#*=======================================================================================================

# At the moment can only handle numerical replacements.
# Also, does not know if a number stored as a string should
# actually be a string.
function replaceMissing!(df::DataFrame; method::String="Mean", display::Bool=true)

    # Replace missing values with the mean.
    if method=="Mean"

        # Loop through the columns.
        for col in names(df)
            # Try and convert the column to a number, for the case where
            # the numbers are stored as a string.

            # If the column is not strings the missing values must be replaced.
            if eltype(df[!,col]) != String
                df[!,col] = coalesce.(df[!,col], mean(skipmissing(df[!,col])))
                end # If.
        end # Loop.

        # Print result to the screen.
        if display
            println("[PREPROCESSING] Dataframe missing values replaced:")
            PrettyTables.pretty_table(df)
            println()
        end #

    end # If.
end # Fnuction.

#*=======================================================================================================
#* Train/Test data split.
#*=======================================================================================================

# Returns: trainX, trainY, testX, testY.
# Optionally shuffles the dataframe and displays the results.
function trainTestSplit(df::DataFrame, yIndex::Int; trainRatio=0.7, shuffleBool::Bool=true, displayBool::Bool=true)

    # Shuffle the dataset.
    if shuffleBool
        df = df[shuffle(axes(df, 1)), :]
    end # If.

    # Train/Test split.
    train, test = splitobs(df, at=trainRatio)

    trainY, trainX = select(train, yIndex), select(train, Not(yIndex))
    testY, testX = select(test, yIndex), select(test, Not(yIndex))

    if displayBool
        println("[PREPROCESSING] TrainX:")
        PrettyTables.pretty_table(trainX)
        println("[PREPROCESSING] TrainY:")
        PrettyTables.pretty_table(trainY)
        println("[PREPROCESSING] TestX:")
        PrettyTables.pretty_table(testX)
        println("[PREPROCESSING] TestY:")
        PrettyTables.pretty_table(testY)
        println()
    end # If.

    return trainX, trainY, testX, testY

end # Function.

#*=======================================================================================================
#*  One hot encoding.
#*=======================================================================================================

function oneHotEncoding!(df::DataFrame, colIndex::Int; displayBool::Bool=true)

    # Apply one hot encoding.
    onehot!(df, colIndex, outnames = Symbol.(unique(df[:,colIndex])))
    select!(df, Not(colIndex))

    # DisplaY results.
    if displayBool
        println("[PREPROCESSING] One hot encoding applied.")
        PrettyTables.pretty_table(df)
        println()
    end # If.

end # Function.

#*=======================================================================================================
#* EOF.
#*=======================================================================================================
