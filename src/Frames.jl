"""Fundamental unit of ID3 data.

ID3 tags are split into frames. Each frame has a potentially
different structure, and so this base class is not very featureful.
"""
abstract type Frame end

"""All supported ID3v2.3/4 frames, keyed by frame name."""
const Frames=Dict(:APIC=>[EncodingSpec("encoding"),
Latin1TextSpec("mime"),
PictureTypeSpec("type"),
EncodedTextSpec("desc"),
BinaryDataSpec("data")],
:TextFrame=>[EncodingSpec("encoding"),
EncodedTextSpec("text")],
:COMM=>[    EncodingSpec("encoding"),
    StringSpec("lang", length=3),
    EncodedTextSpec("desc"),
    EncodedTextSpec("text")],
:NumericPartTextFrame=>[
    EncodingSpec("encoding"),
    EncodedNumericPartTextSpec("text")
]
)
Base.keys(x::Frame)=propertynames(x)

function Frame(frame::T;kw...) where T<:Frame
    a=ntfromstruct(frame)
    for (k,v) in kw
        if haskey(a,k)
            a=merge(a,(k=>v,))
        end
    end
    structfromnt(T,a)
end

"""Attached (or linked) Picture.

Attributes:

* encoding -- text encoding for the description
* mime -- a MIME type (e.g. image/jpeg) or '-->' if the data is a URI
* type -- the source of the image (3 is the album front cover)
* desc -- a text description of the image
* data -- raw image data, as a byte string

Methods:
APIC(x::Vector{UInt8})
APIC(Attributes...)
# Examples
```julia-repl
julia> read(data::Vector{UInt8},APIC)

julia> APIC(ID3v2.LATIN1, "image/jpg", ID3v2.OTHER, "",image)
```
"""
struct APIC <:Frame
    encoding::Encodings
    mime
    type::PictureType
    desc
    data::Vector{UInt8}
end
function APIC(x::Vector{UInt8})
    _framespec=Frames[:APIC]
    read(x,_framespec,APIC)
end
function pretty(s::APIC)
    println(" type($(Int(s.type)), $(s.type)) mime($(s.mime)) size($(length(s.data)))")
end
function Base.read(x::Vector{UInt8},::Type{T}) where T<:Frame
    _framespec=Frames[nameof(T)]
    read(x,_framespec,T)
end
function Base.read(x::Vector{UInt8},::T) where T<:Frame
    _framespec=Frames[nameof(T)]
    read(x,_framespec,T)
end
"""Text strings.

Text frames support casts to unicode or str objects, as well as
list-like indexing, extend, and append.

Iterating over a TextFrame iterates over its strings, not its
characters.

Text frames have a 'text' attribute which is the list of strings,
and an 'encoding' attribute; 0 for ISO-8859 1, 1 UTF-16, 2 for
UTF-16BE, and 3 for UTF-8. If you don't want to worry about
encodings, just set it to 3.

Attributes:

* encoding -- text encoding for the description
* text -- a text description
"""
struct TextFrame<:Frame
    encoding::Encodings
    text::AbstractString
end

function TextFrame(x::Vector{UInt8})
    _framespec=Frames[:TextFrame]
    read(x,_framespec,TextFrame)
end

function Base.write(x::T) where T<:Frame
    # res=[write(x.encoding)]
    # for i in ntfromstruct(x)
    #     push!(res,write(i))
    res=Vector{UInt8}()
    for i in Frames[nameof(T)]
        append!(res,write(x,i))
    end
    res
end
function Base.show(io::IO,::MIME"text/plain",s::TextFrame)
    # println(io,name," ","language()")
    print(io,s.encoding," ",s.text)
end
function pretty(s::TextFrame)
    println(" language(",hasproperty(s,:lang) ? s.lang : "",")")
    println(s.encoding," ",s.text)
end

"""User comment.

User comment frames have a description, like TXXX, and also a three
letter ISO language code in the 'lang' attribute.

Attributes:

* encoding -- text encoding for the description
* lang
* desc -- a text description
* text -- a text
"""
struct COMM <:Frame
    encoding::Encodings
    lang::AbstractString
    desc::AbstractString
    text::AbstractString
end
function COMM(x::Vector{UInt8})
    _framespec= [
        EncodingSpec("encoding"),
        StringSpec("lang", length=3),
        EncodedTextSpec("desc"),
        EncodedTextSpec("text")
    ]
    read(x,_framespec,COMM)
end
function pretty(s::COMM)
    println(" description($(s.desc)) language($(s.lang)):")
    println(s.encoding," ",s.text)
end
"""Multivalue numerical text strings.

These strings indicate 'part (e.g. track) X of Y', and unary plus
returns the first value::
# Examples
```julia-repl
julia> frame = TRCK("4")
ID3v2.NumericPartTextFrame(ID3v2.UTF16, "4"))
track = merge(track,(TRCK=frame,)) # track == 4
(TRCK = ID3v2.NumericPartTextFrame(ID3v2.UTF16, "1"),)
```
"""
struct NumericPartTextFrame<:Frame
    encoding::Encodings
    text::AbstractString
end
function NumericPartTextFrame(x::Vector{UInt8})
    _framespec= [
        EncodingSpec("encoding"),
        EncodedNumericPartTextSpec("text")
    ]
    read(x,_framespec,NumericPartTextFrame)
end
NumericPartTextFrame(x::AbstractString)=NumericPartTextFrame(UTF16,x)
function pretty(s::NumericPartTextFrame)
    println(" language(",hasproperty(s,:lang) ? s.lang : "",")")
    println(s.encoding," ",s.text)
end
"Track Number"
TRCK=NumericPartTextFrame

"Part of set"
TPOS=NumericPartTextFrame

"Title"
TIT2=TextFrame

"Encoder"
TENC=TextFrame

"Lyricist"
TEXT=TextFrame

"File type"
TFLT=TextFrame

"iTunes Podcast Identifier"
TGID=TextFrame

"Time of recording (HHMM)"
TIME=TextFrame

"Content group description"
TIT1=TextFrame

"Title"
TIT2=TextFrame

"Subtitle/Description refinement"
TIT3=TextFrame

"Starting Key"
TKEY=TextFrame

"Audio Languages"
TLAN=TextFrame

"Audio Length (ms)"
Tmeri=TextFrame

"Source Media Type"
TMED=TextFrame

"Mood"
TMOO=TextFrame

"Original Album"
TOAL=TextFrame

"Original Filename"
TOFN=TextFrame

"Original Lyricist"
TOLY=TextFrame

"Original Artist/Performer"
TOPE=TextFrame

"Original Release Year"
Tmeri=TextFrame

"Owner/Licensee"
TOWN=TextFrame

"Lead Artist/Performer/Soloist/Group"
TPE1=TextFrame

"Band/Orchestra/Accompaniment"
TPE2=TextFrame

"Conductor"
TPE3=TextFrame

"Interpreter/Remixer/Modifier"
TPE4=TextFrame

"Encoder settings"
TSSE=TextFrame

"Album"
TALB=TextFrame