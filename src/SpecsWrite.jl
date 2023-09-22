Base.write(frame::Frame,::EncodingSpec)=[UInt8(frame.encoding)]
function Base.write(frame::Frame,spec::EncodedTextSpec)
    # append!(x,
    vcat(encode(getproperty(frame,Symbol(name(spec))),Encoding(_encodings1[frame.encoding])),
    _encodings[frame.encoding])
    # )
end
Base.write(frame::Frame,spec::PictureTypeSpec)=UInt8(getproperty(frame,Symbol(name(spec))))
Base.write(frame::Frame,spec::BinaryDataSpec)=getproperty(frame,Symbol(name(spec)))
Base.write(frame::Frame,spec::StringSpec)=
codeunits(getproperty(frame,Symbol(name(spec))))
Base.write(frame::Frame,spec::Latin1TextSpec)=
vcat(codeunits(getproperty(frame,Symbol(name(spec)))),zeros(UInt8,1))

