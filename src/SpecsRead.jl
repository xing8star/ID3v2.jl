function Base.read(x::Vector{UInt8},framespec::Vector{Spec},::Type{T}) where T<:Frame
    structfromnt(T,read(x,framespec))
end