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
    frames = readdir(dir)
    return Dict(f => get_result(joinpath(dir,f), "Optimal") for f in frames)
end

function get_results()
    # Metadata.
    current_file_path = dirname(@__FILE__)
    types = [ "Standard", "Temporal" ] 
    persons = [ "1-Person", "2-Persons" ] 
    models = [ "LeNet5Adapted" ] 

    # Load all results.
    return Dict(
        t => Dict(
            p => Dict(
                m => get_frame_results(joinpath(current_file_path, "Runs", t, p, m)) for m in models
            ) for p in persons
        ) for t in types
    )
end

function generate_acc_graph()
    results = get_results()
    display(results)
end

generate_acc_graph()
