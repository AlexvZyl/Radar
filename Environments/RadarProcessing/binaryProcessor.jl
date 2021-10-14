# Setup.
clearconsole();

# ============================================================ #
# Packages.                                                    #
# ============================================================ #

# Drawing engine.
using GLMakie
# Set Makie theme.
set_theme!(theme_dark())

using DataFrames
using FloatingTableView

# ============================================================ #
# Binary file format.                                          #
# ============================================================ #

# Data file consists of rpds, I, Q, rpds, I, Q ...
#   193 pulse header (rpds) bytes
#   8192 I-data units, 16bit each.
#   8192 Q-data units, 16bit each.
#   ...
#   193 pulse header (rpds) bytes
#   8192 I-data bytes
#   8192 Q-data bytes
# Each 16MB+ file contains 512 of these blocks.

binaryFormat = DataFrame(
    # Component     Size.
    RPDS            = 193,      # 8 Bit.
    I               = 8192,     # 16 Bit.
    Q               = 8192,     # 16 Bit.
    blocks          = 512,      # Total blocks.
    fileSize        = (193+8192*2*2) *
                       512      # 8 Bit.
)

# ============================================================ #

# The RPDS block describes information of the pulse that was
# transmitted for that set of I/Q samples.

RPDS = DataFrame(
    # Data ID.                                Size.     Type.
    unknown1                                = [1, 21,   UInt8],
    signature                               = [1, 1,    UInt32],
    checksumAlgorithm                       = [1, 1,    UInt8],
    endianess                               = [1, 1,    UInt8],
    systemId                                = [1, 1,    UInt16],
    rpdsSize                                = [1, 1,    UInt32],
    dataSize                                = [1, 1,    UInt32],
    messageLength                           = [1, 1,    UInt16],
    azimuth                                 = [1, 1,    UInt16],
    timeStamp                               = [1, 1,    UInt32],
    sweepCount                              = [1, 1,    UInt64],
    scanRate                                = [1, 1,    UInt32],
    rotationRate                            = [1, 1,    UInt16],
    scanAzmStart                            = [1, 1,    UInt16],
    scanAzmStop                             = [1, 1,    UInt16],
    freqIdx                                 = [1, 1,    UInt8],
    scanMode_SweepMode                      = [1, 1,    UInt8],
    maxRange_stagger_compressionBitSize     = [1, 1,    UInt8],
    compressionOverflow_ScanRotation        = [1, 1,    UInt8],
    TDataValid                              = [1, 1,    UInt16],
    TStop                                   = [1, 1,    UInt16],
    TStagger1                               = [1, 1,    UInt16],
    TStagger2                               = [1, 1,    UInt16],
    TStagger3                               = [1, 1,    UInt16],
    freqProfile                             = [1, 1,    UInt32],
    negativeDftw                            = [1, 1,    UInt32],
    compressionOverflowCount                = [1, 1,    UInt16],
    squintAdjust                            = [1, 1,    UInt16],
    unknown2                                = [1, 1,    UInt8],
    filterSelect_sidebandSelect             = [1, 1,    UInt8],
    unknown3                                = [1, 1,    UInt16],
    checksum                                = [1, 1,    UInt32],
    unknown4                                = [1, 1,    UInt8]
)

# ============================================================ #
# Binary processing script.
# ============================================================ #

# Create a dataframe to contain the data.
v_RPDS = [Vector{UInt8}(undef, binaryFormat.RPDS[1]) for _ in 1:binaryFormat.blocks[1]]
v_I = [Vector{UInt16}(undef, (binaryFormat.I[1])) for _ in 1:binaryFormat.blocks[1]]
v_Q = [Vector{UInt16}(undef, (binaryFormat.Q[1])) for _ in 1:binaryFormat.blocks[1]]
rawDataDF = DataFrame(
    RPDS    = v_RPDS,
    I       = v_I,
    Q       = v_Q
)

# Read the byte data into a tepmp variable.
file = "Environments\\RadarProcessing\\RadarData-Binary\\Rhino\\Capture_1000.bin";
readVariable = Vector{UInt8}(
    undef,
    binaryFormat.I[1]*2 + binaryFormat.Q[1]*2 + binaryFormat.RPDS[1]
)
read!(file, readVariable)

# Store RPDS.
rawDataDF.RPDS[1] = readVariable[1:binaryFormat.RPDS[1]]
# Store I samples.
offset = binaryFormat.RPDS[1]
rawDataDF.I[1] = reinterpret(UInt16, readVariable[offset+1:offset+binaryFormat.I[1]*2])
offset += binaryFormat.I[1]*2;
rawDataDF.Q[1] = reinterpret(UInt16, readVariable[offset+1:offset+binaryFormat.Q[1]*2])

# ============================================================ #
# Plotting.
# ============================================================ #

f = Figure()

ax = Axis(f[1, 1], xlabel = "I Channel", ylabel = "Value",
    title = "Pulse 0 For Rhino Bin")
scatter!(rawDataDF.I[1])

display(f)

# ============================================================ #
println("EOS.")
# ============================================================ #
