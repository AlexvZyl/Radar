# ============================================================ #
# Packages.                                                    #
# ============================================================ #

# Optimizing.
using FLoops

# Data.
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
#   8192 I-data units, 16bit each.
#   8192 Q-data units, 16bit each.
# Each 16MB+ file contains 512 of these pulses.

binaryFormat = DataFrame(
    # Component     Size.
    RPDS            = 193,      # Bytes total.
    I               = 8192*2,   # Bytes total, stored as 16 Bit per sample.
    Q               = 8192*2,   # Bytes total, stored as 16 Bit per sample.
    pulses          = 512,      # Total pulses (pulses).
    fileSize        = (193 + 8192*2*2) *
                       512      # Size given in bytes.
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
# Binary File.                                                 #
# ============================================================ #

# This function reads the binary files based on the format described above.
# It then places all of the data in a dataframe.
function readBinaryFile(filePath::String; draw::Bool=false)

    # Create a dataframe to contain the file with 512 pulses.
    v_RPDS = [Vector{UInt8}(undef, binaryFormat.RPDS[1]) for _ in 1:binaryFormat.pulses[1]]
    v_I = [Vector{Int16}(undef, binaryFormat.I[1]) for _ in 1:binaryFormat.pulses[1]]
    v_Q = [Vector{Int16}(undef, binaryFormat.Q[1]) for _ in 1:binaryFormat.pulses[1]]
    rawDataDF = DataFrame(
        RPDS    = v_RPDS,
        I       = v_I,
        Q       = v_Q
    )

    # First we need to read the entire file (all the bytes) into a vector.
    rawFile = Vector{UInt8}(
        undef,
        binaryFormat.fileSize[1]
    )
    read!(filePath, rawFile)

    # This file consists of pulses (512) and each pulse consists of I/Q channels.
    # Each channel is divided into 8 segments.  Each segment contains a LSByte and
    # MSByte buffer which has to be interleaved to get the correct rersult.

    # Need a varaible to keep track of looping through the file.
    fileOffset = 0

    # Seperate the buffers and store them in a vector.
    I_buffers = [ Vector{UInt8}(undef, 1024) for _ in 1:16 ]
    Q_buffers = [ Vector{UInt8}(undef, 1024) for _ in 1:16 ]

    # Loop through the pulses and store the data.
    for i = 1:binaryFormat.pulses[1]

        # Store RPDS.
        rawDataDF.RPDS[i] = rawFile[fileOffset+1:fileOffset+binaryFormat.RPDS[1]]
        # Need to skip the header.
        bufferOffset = binaryFormat.RPDS[1]

        # I channel.
        for b in 1:16
            totalOffset = bufferOffset + fileOffset
            I_buffers[b] = rawFile[1+totalOffset:1024+totalOffset]
            bufferOffset += 1024;
        end # Loop.
        # Q Channel.
        for b in 1:16
            totalOffset = bufferOffset + fileOffset
            Q_buffers[b] = rawFile[1+totalOffset:1024+totalOffset]
            bufferOffset += 1024;
        end # Loop.

        # Interleave the data and store it in a dataframe.
        I_data = Vector{UInt8}(undef, 0)
        Q_data = Vector{UInt8}(undef, 0)
        for buffer in 1:2:16
            for bit in 1:1024
                append!(I_data, [ I_buffers[buffer][bit],  I_buffers[buffer+1][bit] ])
                append!(Q_data, [ Q_buffers[buffer][bit],  Q_buffers[buffer+1][bit] ])
            end # For.
        end # For.

        # Store I samples.
        rawDataDF.I[i] = reinterpret(Int16, I_data)
        # rawDataDF.I[i] = bswap.(reinterpret(Int16, I_data))
        # Store Q samples.
        rawDataDF.Q[i] = reinterpret(Int16, Q_data)
        # rawDataDF.Q[i] = bswap.(reinterpret(Int16, Q_data))

        # Add to the file offset.
        fileOffset += binaryFormat.I[1]+binaryFormat.RPDS[1]

    end # Loop.

    if draw
        # Plot the data.
        f = Figure()
        # 2D Plotting the pulses.
        ax = Axis(f[1, 1], xlabel = "Samples", ylabel = "Value", title = "Binary File Data")
        xlims!(ax, 0, 8200)
        ylims!(ax, -18000, 18000)
        plt1 = scatter!(rawDataDF.I[200])
        plt2 = scatter!(rawDataDF.Q[200])
        legend = Legend(
            f[1,2],
            [plt1, plt2],
            ["I Channel", "Q Channel"]
        )
        display(f)
    end # If.

    # Return the dataframe containin the file information.
    return rawDataDF

end # Function.

# ============================================================ #
# Binary Folder.                                               #
# ============================================================ #

# This functions reads all of the binary files in the given
# folder and stores them in a vector of dataframes.
function readBinaryFolder(folderPath::String)
    # Create a list of all the files in the directory.
    files = readdir(folderPath)
    # Create a vector that contains the data of all of the files.
    dataVector = [DataFrame() for _ in 1:length(files)]
    # Iterate thrpugh the files and store the data in the vector.
    Threads.@threads for i in 1:length(files)
        dataVector[i] = readBinaryFile(string(folderPath, files[i]))
    end # For.
    # Return the vector of dataframes.
    return dataVector
end # Function

# ============================================================ #
# Binary Folder.                                               #
# ============================================================ #

# There are some areas in the files that have deadzones.
# This function removes them.
function removeDeadZones(dirtyData::Vector{UInt16})
    # Half of the areas are "dead".  That means 4096 samples.
    # Each "block" has 8 deadzones and 8 zones with data.
    cleanData = Vector{Uint16}(undef, binaryFormat.I[1]/2)
    # Loop through the data and remove dead areas.
    offset = binaryFormat.I[1]/2
    for i in 1:8
        cleanData[offset*i:offset*i+binaryFormat.I[1]] = dirtyData[offset*i:offset*i+binaryFormat.I[1]]
    end # For.
    return cleanData
end # Function.

# ============================================================ #
