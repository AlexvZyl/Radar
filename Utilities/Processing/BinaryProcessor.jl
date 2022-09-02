# Describes the file's metadata.
mutable struct Meta_Data
    sampling_freq::Float64
    center_freq::Float64
    wave_sample_count::Int32
    pulse_sample_count::Int32
    PRF::Int32
    dc_freq_shift::Float64
    bandwidth::Float64
    wave_type::String
    total_pulses::Int64
    max_range::Float64

    Meta_Data() = new(0, 0, 0, 0, 0, 0, 0, "", 0, 0) 
end

# Get the value from the string given the position.
# This is a very hacky function...
function parseNumber(string::String, startIndex::Number)

    stringAns = ""
	index = startIndex
    while(string[index]!=' ' && string[index]!='\n')
		stringAns = stringAns * string[index]
		index += 1
        if index>length(string) break end
	end
	return parse(Float64, stringAns)

end

# Reads the metadata from the file and returns a struct containing the data.
function load_meta_data(file::String)

    meta_data = Meta_Data()

    # Iterate over the file lines.
    for line in eachline(abspath(file))
    
    	if isnothing(findfirst("TX sampling rate", line)) == false    
    		meta_data.sampling_freq = trunc(Int32, parseNumber(line, 19)*1e6)
    		
    	elseif isnothing(findfirst("TX wave frequency", line)) == false
    		meta_data.center_freq = parseNumber(line, 20)*1e6
    
    	elseif isnothing(findfirst("Radar Waveform Samples", line)) == false
            meta_data.wave_sample_count	= Int32(parseNumber(line, 25))
    
    	elseif isnothing(findfirst("Radar Pulse Samples", line)) == false
    		meta_data.pulse_sample_count = Int32(parseNumber(line, 22))
    
    	elseif isnothing(findfirst("PRF", line)) == false
    		meta_data.PRF = parseNumber(line, 6)
    
    	elseif isnothing(findfirst("DC Frequency Offset Actual", line)) == false
    		meta_data.dc_freq_shift = parseNumber(line, 29)
    
    	elseif isnothing(findfirst("Wave bandwidth", line)) == false
    		meta_data.bandwidth = parseNumber(line, 17) * 1e6
    
    	elseif isnothing(findfirst("Wave type", line)) == false
    		if isnothing(findfirst("Linear Frequency Chirp", line)) == false
                meta_data.wave_type = "LFM"
    		elseif isnothing(findfirst("Optimal Bezier", line)) == false
                meta_data.wave_type = "Bezier"
    		elseif isnothing(findfirst("Optimal Logit", line)) == false
                meta_data.wave_type = "Logit"	
            end
    
    	elseif isnothing(findfirst("Total pulses", line)) == false
            meta_data.total_pulses  = Int32(parseNumber(line, 15)) - 10 # Remove 10 pulses just to be safe.  This can cause issues...
    
        elseif isnothing(findfirst("Radar max range", line)) == false
    		meta_data.max_range	= parseNumber(line, 18)
    
    	end
    
    end
    return meta_data
end

# Process binary file.
function loadDataFromBin(file::String, meta_data::Meta_Data; pulsesToLoad::Number=0)

	# If a certain amount of pulses that were specified.
	if pulsesToLoad != 0

		rawData = Array{Float64}(undef, pulsesToLoad*meta_data.pulse_sample_count*2)

	# Load all of the data.
	else

		# Data sizes.
		fileSizeBytes = filesize(file)
		fileSizeFloats = trunc(Int, (fileSizeBytes / 8))
		# Read the raw data.
		rawData = Array{Float64}(undef, fileSizeFloats)

	end
	
	# Read the file.
	read!(file, rawData)

	# Load the channels.
	Ichannel = rawData[1:2:end]
	Qchannel = rawData[2:2:end]

	# Create and return complex vector.
	return Ichannel + im*Qchannel

end
