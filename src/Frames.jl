abstract type Frame end
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
struct APIC <:Frame
    encoding::Encodings
    mime
    type::PictureType
    desc
    data::Vector{UInt8}
end
function APIC(x)
    _framespec=[EncodingSpec("encoding"),
    Latin1TextSpec("mime"),
    PictureTypeSpec("type"),
    EncodedTextSpec("desc"),
    BinaryDataSpec("data")]
    res=read(x,_framespec)
    structfromnt(APIC,res)
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
struct TextFrame<:Frame
    encoding::Encodings
    text::AbstractString
end

function TextFrame(x::Vector{UInt8})
    _framespec=[EncodingSpec("encoding"),
    EncodedTextSpec("text")]
    res=read(x,_framespec)
    structfromnt(TextFrame,res)
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

    frame = TRCK('4/15')
    track = +frame # track == 4
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


TSSE=TextFrame

"Album"
TALB=TextFrame