include("WaveformSpecs.jl")
include("../../Utilities/MakieGL/PlotUtilities.jl")
include("Bezier.jl")
include("../../Utilities/Processing/ProcessingHeader.jl")
include("Utilities.jl")

figure = Figure(resolution = (1920, 1080)) # 2D



save("Article_LowTBP_Comparisson_No_Bezier.pdf", figure)

