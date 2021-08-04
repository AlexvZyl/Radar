
# This package is created to handle the imports of all of the packages and functions that
# are needed to do ML in julia.
# Seems like the environemnt of Julia is still a bit deurmekaar.

#*=======================================================================================================
#* Drawing and viewing
#*=======================================================================================================

using Plots
using TableView

#*=======================================================================================================
#* Data handling.
#*=======================================================================================================

# Data.
using RDatasets
using DataFrames
using CSV
using DataConvenience:onehot!
using MLDataUtils:splitobs
using StatsBase:standardize

#*=======================================================================================================
#* Mathematics, Statistics and Machine Learning.
#*=======================================================================================================

# Math, Stats and ML.
using Flux
using MLJ

#*=======================================================================================================
#* EOF.
#*=======================================================================================================
