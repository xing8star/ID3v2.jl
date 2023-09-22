export EasyID3
const EasyID3Map=Dict(
    :TALB=>"album",
    :TBPM=>"bpm",
    :TCMP=>"compilation",  # iTunes extension
    :TCOM=>"composer",
    :TCOP=>"copyright",
    :TENC=>"encodedby",
    :TEXT=>"lyricist",
    :TLEN=>"length",
    :TMED=>"media",
    :TMOO=>"mood",
    :TIT1=>"grouping",
    :TIT2=>"title",
    :TIT3=>"version",
    :TPE1=>"artist",
    :TPE2=>"albumartist",
    :TPE3=>"conductor",
    :TPE4=>"arranger",
    :TPOS=>"discnumber",
    :TPUB=>"organization",
    :TRCK=>"tracknumber",
    :TOLY=>"author",
    :TSO2=>"albumartistsort",  # iTunes extension
    :TSOA=>"albumsort",
    :TSOC=>"composersort",  # iTunes extension
    :TSOP=>"artistsort",
    :TSOT=>"titlesort",
    :TSRC=>"isrc",
    :TSST=>"discsubtitle",
    :TLAN=>"language"
)

function EasyID3(x::NamedTuple)
    res=Dict{String,Frame}()
    for (k,v) in convert(Vector{Pair},x)
        if haskey(EasyID3Map,k)
            res[EasyID3Map[k]]=v
        end
    end
    res
end

EasyID3(x::ID3)=EasyID3(x.ID3Tags)
EasyID3(x::AbstractString)=EasyID3(ID3(x).ID3Tags)
