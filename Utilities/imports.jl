
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
using Statistics

#*=======================================================================================================
#* EOF.
#*=======================================================================================================
