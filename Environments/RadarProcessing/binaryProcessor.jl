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
#   8192 I-data bytes
#   8192 Q-data bytes
#   ...
#   193 pulse header (rpds) bytes
#   8192 I-data bytes
#   8192 Q-data bytes
# Each 16MB+ file contains 512 of these blocks.

binaryFormat = DataFrame(
    # Component     Size.
    RPDS            = 193,  # Bytes.
    I               = 8192, # Bytes.
    Q               = 8192, # Bytes.
    blocks          = 512   # Total blocks.
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

fileSizeBytes = (binaryFormat.I+binaryFormat.Q+binaryFormat.RPDS)[1] * binaryFormat.blocks[1];

# ============================================================ #
println("EOS.")
# ============================================================ #
