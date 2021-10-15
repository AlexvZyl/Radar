# JuliaRepo

Repository for the Julia code used in my Master's degree.

# Julia Docs and Packages

* Julia documentation: [https://docs.julialang.org/en/v1/].   
* Flux: [https://fluxml.ai/Flux.jl/stable/].  
* MLJ: [https://alan-turing-institute.github.io/MLJ.jl/dev].  
* KNet: [https://denizyuret.github.io/Knet.jl/latest/].
* Zygote: [https://fluxml.ai/Zygote.jl/latest/].
* Data Convenience: [https://github.com/xiaodaigh/DataConvenience.jl].
* FloatingTableView: Julia dataframes do not display nicely in the terminal and this packages overcomes that, [https://github.com/pdeffebach/FloatingTableView.jl].
* Makie: Plotting library with an OpenGL backend, [https://github.com/JuliaPlots/Makie.jl].

# Learning Resources

* Julia Academy: [https://juliaacademy.com/].
* Chris Rackauckas: [https://julialang.org/jsoc/gsoc/sciml/].
* Neural Networks by the coding train: [https://www.youtube.com/watch?v=XJ7HLz9VYz0&list=PLRqwX-V7Uu6aCibgK1PTWWu9by6XFdCfh].
* Machine Learning course on Udemy: [https://www.udemy.com/course/machinelearning/learn/lecture/6087180#overview].
* Statistical Learning: [https://www.statlearning.com/].

# Resolving Errors

* Plots.jl not building? "]add x264_jll@v2019.5.25", [https://github.com/JuliaLang/julia/issues/36893].
* Sometimes the packages do not build properly, just restart Julia ("CRTL+D" in the REPL, run "exit()" or restart IDE).
* StatsFuns breaking compilation? "** incremental compilation may be fatally broken for this module **" : ]add StatsFuns@0.9.3
* CSV.jl version 0.8.5 does something weird with Parsers.jl, bypass with "]add CSV#main"

# Create Local Package

*The new method uses PkgTemplates.jl, [https://github.com/invenia/PkgTemplates.jl]*

A helpful article, [https://medium.com/coffee-in-a-klein-bottle/developing-your-julia-package-682c1d309507].

* ] add PkgTemplates
* using PkgTemplates
* generate("PackageName")
* A menu pops up, check the Dir box as a minimum.
* Your package will be in the path.
* Add the pacakge locally to environtment: Pkg.develop(PackageSpec(path="directory")).

*This method has been deprecated.*
* Go to directory where the package should be with 'cd("path")'.
* Create package with '] generate PackageName'.
* Add dependencies by using '] activate .' and '] add PackageName'.
* Add local package: Pkg.develop(PackageSpec(path="directory")).

# Datasets

* RDataSets.jl: Datasets used in R, [https://github.com/JuliaStats/RDatasets.jl].
* MLDataSets.jl: Common datasets used in ML, [https://github.com/JuliaML/MLDatasets.jl].
* GraphMLDatasets.jl: For graphing datasets, [https://github.com/yuehhua/GraphMLDatasets.jl].

# Notes

* Which statistics package to use?  Statistics.jl, "StatsBase is most likely going to be moved in part to Statistics, and in part to other packages (like StatsModels). See e.g. [https://github.com/JuliaLang/julia/pull/27152]."
