include("../../Utilities/MakieGL/MakieGL.jl")
include("Types.jl")

function parse_number(file::IOStream, section::String, key::String)
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
            return parse(Float64, replace(line, key*": " => ""))
        end
    end

    # If we didn't find the key, return an error
    error("Could not find \"$key\" in section \"$section\".")
end

function get_results(path::String, section::String)
    open(path, "r") do file
        return TrainingResults(
            parse_number(file, section, "Training Accuracy"),
            parse_number(file, section, "Training Loss"),
            parse_number(file, section, "Testing Accuracy"),
            parse_number(file, section, "Testing Loss"),
            0
        )
    end
end


