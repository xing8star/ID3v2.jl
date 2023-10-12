export ID3,version,header,
save,pretty,
MPG123
struct ID3
    header::ID3Header
    ID3Tags::NamedTuple
end
struct MPG123
    id3::ID3
    io::IO
end

"""
ID3(file::AbstractString)

# Examples
```julia-repl
julia> ID3("yourmusic.mp3")
ID3(....)
```
"""
function ID3(file::AbstractString)
    io=open(file)
    header=try
        read(io,ID3Header)
    catch ex
        if ex isa ID3NoHeaderError
            @warn "Not found ID3"
            ID3Header(v"2.3.0",0x0,0)
        end
    end
    data=readfull(io,header)
    # close(io)
    seek(io,fullsize(header)+1)
    mark(io)
    ID3(header,data),io
end
MPG123(file::AbstractString)=MPG123(ID3(file)...)
ID3(x::MPG123)=x.id3
header(x::ID3)=x.header
version(x::ID3)=version(x.header)
header(x::MPG123)=header(x)
version(x::MPG123)=version(x)
function writeID3Tags(x::NamedTuple)
    res=Vector{UInt8}()
    for (name,data) in convert(Vector{Pair},x)
        name=codeunits(String(name))
        flags=repeat([0x0],2)
        data=write(data)
        # println(length(data))
        size=paddingint(length(data))
        append!(res,name,size,flags,data)
    end
    res
end
function writeID3Tags(io::IO,x::NamedTuple)
    for (name,data) in convert(Vector{Pair},x)
        name=codeunits(String(name))
        flags=repeat([0x0],2)
        data=write(data)
        size=paddingint(length(data))
        write(io,name,size,flags,data)
    end
end
writeID3Tags(x::ID3)=writeID3Tags(x.ID3Tags)
writeID3Tags(io::IO,x::ID3)=writeID3Tags(io,x.ID3Tags)

function Base.write(x::ID3Header)
    res=[b"ID3"...]
    push!(res,Tuple(version(x))[2:3]...,x.flags)
    res
end
function Base.write(io::IO,x::ID3Header)
    write(io,b"ID3",Tuple(version(x))[2:3]...,x.flags)
end
function Base.write(x::ID3)
    res=write(header(x))
    data=writeID3Tags(x)
    append!(res,BitPaddedInt2bytes(length(data)),data)
    res
end
function Base.write(io::IO,x::ID3)
    write(io,header(x))
    write(io,zeros(UInt8,4))
    writeID3Tags(io,x)
    _size=position(io)-10
    seek(io,6)
    write(io,BitPaddedInt2bytes(_size))
    seekend(io)
end
Base.write(x::MPG123)=write(ID3(x))
Base.write(io::IO,x::MPG123)=write(io,ID3(x))
function save(x::MPG123,file=x.io.name[7:end-1])
    f=tempname(".")
    open(f,"w+") do io
        write(io,write(x))
        write(io,read(x.io))
    end
    # close(x.io)
    reset(x.io)
    mv(f,file, force=true)
end
function save(::Val{:io},x::MPG123,file=x.io.name[7:end-1])
    f=tempname(".")
    open(f,"w+") do io
        write(io,x)
        write(io,read(x.io))
    end
    reset(x.io)
    mv(f,file, force=true)
end
function pretty(s::ID3)
    println("==== ID3v2 Raw frames ====")
    for (name,value) in convert(Vector{Pair},s.ID3Tags)
        print(name)
        pretty(value)
    end
        # println(" ",value.text)
end
pretty(s::MPG123)=pretty(ID3(s))