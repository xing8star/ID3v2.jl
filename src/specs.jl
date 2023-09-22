include("PictureType.jl")
# @recompile_invalidations begin
    using NamedTupleTools
    using StringEncodings
# end
abstract type Spec end
abstract type ByteSpec <: Spec end

# abstract type TextFrame<:Frame end 
struct MultiSpec <:Spec
    name
end
struct EncodingSpec<:Spec
    name
end
name(x::Spec)=x.name
@recompile_invalidations begin

Base.write(_,::Spec)=error("Not implement")

# EncodingSpec(x)=EncodingSpec(get(Encoding,x,"UTF-16BE without BOM"),x)
function Base.read(x::IO,::Type{EncodingSpec})
    x=read(x,1)
    Encodings(x)
end
function Base.read(x::Vector{UInt8},::Type{EncodingSpec})
    Encodings(x[1]),x[2:end]
end
# function Base.read(x::IO,::EncodingSpec)
#     x=read(x,1)
#     get(Encoding,x,"UTF-16BE without BOM")
# end
function Base.read(x::Vector{UInt8},::EncodingSpec)
    Encodings(x[1]),x[2:end]
end
Base.read(x::Vector{UInt8},::MultiSpec)=String(x)
# Base.write(x::Vector{UInt8},::Type{EncodingSpec},frame::Frame)=push!(x,write(x.encoding))


# function Base.read(x,::Type{MultiSpec})
#     x=read(x)
#     MultiSpec(x)
# end
function Base.read(x::Vector{UInt8},framespec::Vector{Spec})
    # res=Dict{String,Any}()
    res=NamedTuple()
    for i in framespec
        a,x=read(x,i,res)
        res=merge(res,(Symbol(name(i))=>a,))
    end
    res
end

Base.read(x::Vector{UInt8},s::Spec,_)=read(x,s)
end #end of recompile


struct Latin1TextSpec<:Spec
    name::AbstractString
end
function Base.read(x::IO,::Latin1TextSpec)
    res=[]
    v=read(x,1)
    while v!=0x0
        push!(res,v)
    end
    String(res)
end
function Base.read(x::Vector{UInt8},::Latin1TextSpec)
    index=findfirst(==(0x0),x)
    String(x[begin:index-1]),x[index+1:end]
end

struct EncodedTextSpec<:Spec
    name::AbstractString
end
# Base.:(-)(::Nothing,_)=nothing
# Base.splice!(a::Vector,::Nothing)=a

EncodedNumericPartTextSpec=EncodedTextSpec

function Base.read(x::Vector{UInt8},::EncodedTextSpec,frame::NamedTuple)
    index=findfirst(_encodings[frame.encoding],x)
    _enc=_encodings1[frame.encoding]
    if index isa Nothing
        decode(x, _enc),[]
    else
        pad=if frame.encoding in [UTF8,LATIN1]
            0 else 1 end
        decode(x[begin:index.start+pad-1],_enc),x[index.start+1:end]
    end
end

# write!(x::Vector{UInt8},a::Spec,_)=write!(x,a)

struct PictureTypeSpec<:ByteSpec
    name::AbstractString
end
# function Base.read(x,::ByteSpec)
#     read(x,1)
# end
# readonebyte(x)=read(x,1)
# function Base.read(x,::PictureTypeSpec)
#     # invoke(Base.read,Tuple{Any,ByteSpec},)
#     PictureType(readonebyte(x))
# end
function Base.read(x::Vector{UInt8},::PictureTypeSpec)
    # invoke(Base.read,Tuple{Any,ByteSpec},)
    PictureType(x[1]),x[2:end]
end
struct BinaryDataSpec<:Spec
    name::AbstractString
end
Base.read(x,::BinaryDataSpec)=read(x)
Base.read(x::Vector{UInt8},::BinaryDataSpec)=x,[]

struct StringSpec<:Spec
    name::AbstractString
    length::Int
end
StringSpec(name;length)=StringSpec(name,length)
Base.length(s::StringSpec)=s.length
function Base.read(x::Vector{UInt8},s::StringSpec)
    x[1:length(s)]|>String,x[length(s)+1:end]
end



# header.version >= header._V23:
# if flags & FLAG23_COMPRESS
#     if len(data) < 4:
#         raise ID3JunkFrameError('frame too small: %r' % data)
#     usize, = unpack('>L', data[:4])
#     data = data[4:]
# if flags & FLAG23_ENCRYPT:
#     raise ID3EncryptionUnsupportedError
# if flags & FLAG23_COMPRESS:
#     try:
#         data = zlib.decompress(data)
#     except zlib.error as err:
#         raise ID3JunkFrameError('zlib: %s: %r' % (err, data))