# ====================== #
#       Constants        #
# ====================== #

const c = 299792458

# ====================== #
#    Parameters          #
# ====================== #

txDuration   	= 1
amplitude    	= 1
samplingFreq 	= 23e6
deadZone     	= 500
maxRange     	= 600
txFreq  		= 900e6

# ====================== #
#         Wave           #
# ====================== #

bandwidth 				= samplingFreq / 2.1

# -------------------
# TX Pulse
# -------------------
chirpNSamples 			= round(Int, (deadZone * 2 / c) * samplingFreq)
if (chirpNSamples%2==0)	chirpNSamples += 1 end
pulseNSamples 			= round(Int, (maxRange * 2 / c) * samplingFreq)
if (pulseNSamples%2==0) pulseNSamples += 1 end
pulsesPerTransmission 	= round(Int, (txDuration * samplingFreq)/pulseNSamples)
samples 			    = floor(-(chirpNSamples-1)/2):floor(((chirpNSamples-1)/2))
pulseSamples 			= floor(-(pulseNSamples-1)/2):floor(((pulseNSamples-1)/2))

# -------------------
# HD TX Pulse
# -------------------
HDSamplingFreq 	       = samplingFreq * 10
HDChirpNSamples 	   = round(Int, (deadZone * 2 / c) * HDSamplingFreq)
if (HDChirpNSamples%2==0)
						HDChirpNSamples += 1 end
HDPulseNSamples	       = round(Int, (maxRange * 2 / c) * HDSamplingFreq)
if (HDPulseNSamples%2==0)
						HDPulseNSamples += 1 end
HDSamples 	           = floor(-(HDChirpNSamples-1)/2):floor(((HDChirpNSamples-1)/2))
HDPulseSamples 	       = floor(-(HDPulseNSamples-1)/2):floor(((HDPulseNSamples-1)/2))

# ====================== #
#         EOF            #
# ====================== #
