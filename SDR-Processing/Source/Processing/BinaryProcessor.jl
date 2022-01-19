# ------------------- #
#  R E A D   D A T A  #
# ------------------- #

function loadDataFromBin(file::String; loadRatio::Number=1)

	# Data sizes.
	fileSizeBytes = filesize(file)
	fileSizeFloats = trunc(Int, (fileSizeBytes / 4))
	fileSizeSamples = fileSizeFloats / 2

	# Read the raw data.
	rawData = Array{Float32}(undef, fileSizeFloats)
	read!(file, rawData)

	# Load channel data.
	samplesToLoad = trunc(Int, fileSizeFloats*loadRatio)
	if samplesToLoad % 2 == 1
		samplesToLoad += 1
	end
	Ichannel = rawData[1:2:samplesToLoad]
	Qchannel = rawData[2:2:samplesToLoad]
	return Ichannel + im*Qchannel

end

# ------- #
#  E O F  #
# ------- #
