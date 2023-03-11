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

function generate_acc_graph()
    colors = [ :red,:blue,:teal ]
    results = get_results()
    resolution = (2560,1440)
    figure = Figure(resolution=resolution, font="Latin Modern Math")
    xticks = 0:5:20
    yticks = 0:25:100
    ax = Axis(figure[1,1], title="Network Accuracy with Varying Parameters", xlabel="Number of Doppler Map Frames", ylabel="Accuracy", xticks=xticks, yticks=yticks)
    ylims!(0,100)
    xlims!(0,20)
   
    p = "1-Person"
    clr = 1
    for (t, _) in results
        for (_, frames_dict) in results[t][p]
            if !isnothing(frames_dict)
                frames_int, frame_results = sorted_frames(frames_dict)
                scatterlines!(ax, frames_int, [ x.train_acc for x in frame_results ], markersize=dotSize*4, linewidth=2, marker=:cross, color=colors[clr])
                scatterlines!(ax, frames_int, [ x.test_acc for x in frame_results ], markersize=dotSize*4, linewidth=2, marker=:diamond, color=colors[clr])
                clr+=1
            end
        end
    end

    # axislegend(ax, valign = :bottom, orientation = :horizontal, padding=16)
    save("NetworkAccuracyComparison.pdf", figure)
end

generate_acc_graph()
