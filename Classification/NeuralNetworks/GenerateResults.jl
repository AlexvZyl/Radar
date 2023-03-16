using Base: catch_stack
using GLMakie: TRIANGLE
include("../../Utilities/MakieGL/MakieGL.jl")
include("Types.jl")
include("../Utilities.jl")

function parse_number(file::IOStream, section::String, key::String, type = Float64)
    # Initialize a flag to indicate whether we are in the desired section.
    in_section = false

    # Iterate over each line of the file.
    for line in eachline(file)
        # Check if we have reached the desired section.
        if occursin(section, line)
            in_section = true
        # Check if we are in the desired section and have found the desired key.
        elseif in_section && occursin(key, line)
            # Reset cursor.
            seek(file, 0)
            # Extract the numeric value using regular expressions.
            return parse(type, replace(line, key*": " => ""))
        end
    end

    # If we didn't find the key, return an error
    @error "Could not find \"$key\" in section \"$section\"."
    return 0
end

function get_result(path::String, section::String)
    file_path = joinpath(path,"state.txt")
    if !isfile(file_path)
        @warn "File does not exist at $file_path."
        return TrainingResults(0,0,0,0,0)
    end

    open(file_path, "r") do file
        return TrainingResults(
            parse_number(file, section, "Training Accuracy"),
            parse_number(file, section, "Training Loss"),
            parse_number(file, section, "Testing Accuracy"),
            parse_number(file, section, "Testing Loss"),
            parse_number(file, section, "Epoch", Int32)
        )
    end
end

function get_frame_results(dir::String)
    try 
        frames = readdir(dir)
        return Dict(f => get_result(joinpath(dir,f), "Optimal") for f in frames)
    catch
        return nothing         
    end
end

function get_results()
    # Metadata.
    current_file_path = dirname(@__FILE__)
    types = [ "Standard", "Temporal" ] 
    persons = [ "1-Person", "2-Persons" ] 
    models = [ "LeNet5Adapted", "AlexNet" ] 

    # Load all results.
    return Dict(
        t => Dict(
            p => Dict(
                m => get_frame_results(joinpath(current_file_path, "Runs", t, p, m)) for m in models
            ) for p in persons
        ) for t in types
    )
end

function sorted_frames(frames::Dict{String, TrainingResults})
    keys_sorted = sort(collect(keys(frames)), by = x -> parse(Int, split(x, "-")[1]))
    values = [ frames[k] for k in keys_sorted ]
    keys_int = [ parse(Int, split(x, "-")[1]) for x in keys_sorted]
    return keys_int, values
end

function generate_acc_graph(persons::String)
    persons_title = persons=="1-Person" ? "Same Person" : "Separate Persons"
    colors = [ :teal,:blue,:orange ]
    results = get_results()
    resolution = (2560,1440)
    figure = Figure(resolution=resolution)
    legend_grid = GridLayout()
    legend_grid[1:2,1] = [ Axis(figure; leftspinevisible=false, rightspinevisible=false, topspinevisible=false, bottomspinevisible=false, xgridvisible=false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, xticksvisible=false, yticksvisible=false) for _ in 1:2 ]
    figure.layout[1,2] = legend_grid
    xticks = 0:5:20
    yticks = 0:25:100
    ax = Axis(figure[1,1], title="Model Accuracies ($persons_title Train & Test)", xlabel="Number of Doppler Map Frames", ylabel="Model Accuracy (%)", xticks=xticks, yticks=yticks)
    ylims!(-7,107)
    xlims!(-1,21)
    labels = []
   
    clr = 1
    for (t, _) in results
        for (m, frames_dict) in results[t][persons]
            if !isnothing(frames_dict)
                frames_int, frame_results = sorted_frames(frames_dict)
                scatterlines!(ax, frames_int, [ x.train_acc for x in frame_results ], markersize=dotSize*5, linewidth=3, marker=:cross, color=colors[clr], linestyle=:dash)
                scatterlines!(ax, frames_int, [ x.test_acc for x in frame_results ], markersize=dotSize*5, linewidth=3, marker=:diamond, color=colors[clr])
                clr+=1
                if m == "AlexNet"
                    push!(labels, "  "*m)
                elseif t == "Temporal"
                    push!(labels, "  Temporal")
                elseif t == "Standard"
                    push!(labels, "  LeNet5")
                end
            end
        end
    end

    vlines!([0], color=:black, linewidth=2)
    hlines!([0], color=:black, linewidth=2)


    # Manually create legend.
    markers = []
    for i in 1:3
        push!(markers, MarkerElement(color=colors[i], marker=:circle, markersize=dotSize*5))
    end
    Legend(
        legend_grid[1,1],
        [markers...],
        [labels...],
        "Models",
        valign = :bottom,
        labelfont = "Latin Modern Math",
        titlefont = "Latin Modern Math",
        padding = 30,
        labelsize=45,
        titlesize=50
    )
    points = [ Point2f(-1.5, 0.5), Point2f(2.5, 0.5) ]
    train_legend = [ LineElement(color=:black, linewidth=4, linestyle=:dash, linepoints=points), MarkerElement(color=:black, marker=:cross, markersize=dotSize*5) ]
    test_legend = [ LineElement(color=:black, linewidth=5, linepoints=points), MarkerElement(color=:black, marker=:diamond, markersize=dotSize*5) ]
    labels = [
        "   Training"
        "   Testing"
    ]
    Legend(
        legend_grid[2,1],
        [ train_legend, test_legend ],
        [labels...],
        "Phases",
        valign = :top,
        labelfont = "Latin Modern Math",
        titlefont = "Latin Modern Math", 
        padding = (50,30,30,30),
        labelsize=45,
        titlesize=50
    )

    Makie.save("NetworkAccuracyComparison_$persons.pdf", figure)
end

generate_acc_graph("1-Person")
generate_acc_graph("2-Persons")
