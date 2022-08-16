# ------------------- #
#  R E A D   D A T A  #
# ------------------- #

function loadDataFromBin(file::String; 
						 pulsesToLoad::Number=0, samplesPerPulse::Number=0)

	# If a certain amount of pulses that were specified.
	if pulsesToLoad != 0

		rawData = Array{Float64}(undef, pulsesToLoad*samplesPerPulse*2)

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

# ------- #
#  E O F  #
# ------- #
