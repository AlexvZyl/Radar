
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

# Data.
using RDatasets
using DataFrames
using CSV
using DataConvenience
using MLDataUtils
using MLJ
using StatsBase

#*=======================================================================================================
#* Import file from current directory.
#*=======================================================================================================

# Create a dataframe from the file in the given path and set if it is from
# the current directory or not.
function dataframeFromFile(path::String, fromDirectory::Bool=true, display::Bool=true)

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

    println("[INFO] Dataframe created:")

    # Print the dataframe.
    if display
        PrettyTables.pretty_table(df)
    end # if

    # Return the created dataframe.
    return df

end # Function.

#*=======================================================================================================
#* Feature scaling.
#*=======================================================================================================

# Dataframe feature scaling.
# Dataframe should only contain Bools and numbers.
function featureScaling!(df::DataFrame, type::String="Std")

    # types = ["Std", "Nrm"]
    if type == "Std"
        # Loop through the columns of the datafram
        for col in range(1, stop = ncol(df))
            # Check if column is a number.
            if isa(eltype(df[!, col]), Number)
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
            if eltype(df[!, col]) != Bool
                colMax = maximum(df[:, col])
                colMin = minimum(df[:, col])
                # Apply to rows.
                for row in range(1, stop = nrows(df))
                    df[row, col] = (df[row, col] - colMin) / (colMax - colMin)
                end # loop
            end # if
        end # loop
    end # if

end # function

#*=======================================================================================================
#* Replace missing values.
#*=======================================================================================================

function replaceMissing!(df::DataFrame, method::String="Mean")

    # Replace missing values with the mean.
    if method=="Mean"
        # Loop through the columns.
        for col in range(1, stop=ncol(df))
            # Check if column is a number.
            if eltype(skipmissing(df[!,col])) ∈ Number
                println("True.")
            end # If.
        end # Loop.
    end # If.

end # Fnuction.

#*=======================================================================================================
#* EOF.
#*=======================================================================================================
