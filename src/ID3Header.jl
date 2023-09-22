include("Except.jl")
include("version.jl")
include("util.jl")
include("specs.jl")
include("Frames.jl")
include("SpecsRead.jl")
include("SpecsWrite.jl")

export ID3Header,
readfull,
fullsize,
restsize
struct ID3Header
    version::VersionNumber
    flags::UInt8
    restsize::Int
end
function Base.Tuple(x::VersionNumber)
    (x.major,x.minor,x.patch).|>UInt8
end
function Base.read(io::IO,::Type{ID3Header})
    data=read(io,10)
    id3=data[1:3]|>String
    if id3!="ID3" throw(ID3NoHeaderError()) end
    vmaj=data[4]|>Int
    vrev=data[5]|>Int
    flags=data[6]|>UInt8
    size=data[7:end]|>BitPaddedInt
    version=VersionNumber(2, vmaj, vrev)
    ID3Header(version,flags,size)
end
restsize(x::ID3Header)=x.restsize
fullsize(x::ID3Header)=restsize(x)+10
version(x::ID3Header)=x.version

function paddingint(x::Int)
    lpad(string(x,base=16),8,"0")|>hex2bytes
end


function readfull(io::IO,x::ID3Header)::NamedTuple
    # res=Dict{String,Any}()
    local res::NamedTuple=NamedTuple()
    # arr=[]
    while position(io)<fullsize(x)
        name=read(io,4)|>String
        size=read(io,4)
        flags=read(io,2)
        flags=parse(UInt16,bytes2hex(flags),base=16)
        size=parse(UInt32,bytes2hex(size),base=16)
        t=name[end]=='\0'
        # println(t)
        if t break end
        if size==0 continue end
        framedata=read(io,size)
        name=Symbol(name)
        if isdefined(@__MODULE__,name)
        # if haskey(Frames,name)
        # println(name)
        #    append!(res,name=>Frames[name](framedata))
        # res=merge(res,(name=>eval(:(read($framedata,$name))),))

        # res[name]=eval(:($(Symbol(name))($framedata)))
        res=merge(res,(name=>eval(:($(name)($framedata))),))
        # push!(arr,@async (name=>eval(:($(name)($framedata))),))
        end
    end
    # foreach(arr) do i
    #     res=merge(res,fetch(i))
    # end
    # Dict(res)
    res
end

