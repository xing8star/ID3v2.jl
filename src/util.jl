function BitPaddedInt(x, bits=7, bigendian=true)
    mask = UInt8(1 << (bits)) - 1
    numeric_value = 0
    shift = 0
    value = if bigendian reverse(x) else x end
    for byte in value
        numeric_value += (byte & mask) << shift
        shift += 7
    end
    numeric_value
end

function BitPaddedInt(x::Integer, bits=7)
    mask = UInt8(1 << (bits)) - 1
    numeric_value = 0
    shift = 0
    if x < 0
        error("Value Error")
    end
    while x!=0
        numeric_value += (x & mask) << shift
        x >>= 8
        shift += bits
    end
    numeric_value
end

function BitPaddedInt2bytes(x,bits=7,bigendian=true)
    mask = UInt8(1 << bits) - 1
    index = 1
    bytes_ = zeros(UInt8,4)
    while x!=0
        bytes_[index] = x & mask
        x >>= bits
        index += 1
    end
    if bigendian reverse(bytes_) else bytes_ end
end