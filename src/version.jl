@setup_workload begin
_V24 = VersionNumber(2, 4, 0)
_V23 = VersionNumber(2, 3, 0)
_V22 = VersionNumber(2, 2, 0)
_V11 = VersionNumber(1, 1)

FLAG23_ALTERTAG = 0x8000
FLAG23_ALTERFILE = 0x4000
FLAG23_READONLY = 0x2000
FLAG23_COMPRESS = 0x0080
FLAG23_ENCRYPT = 0x0040
FLAG23_GROUP = 0x0020

FLAG24_ALTERTAG = 0x4000
FLAG24_ALTERFILE = 0x2000
FLAG24_READONLY = 0x1000
FLAG24_GROUPID = 0x0040
FLAG24_COMPRESS = 0x0008
FLAG24_ENCRYPT = 0x0004
FLAG24_UNSYNCH = 0x0002
FLAG24_DATALEN = 0x0001

@enum Encodings begin
LATIN1 = 0
# """ISO-8859-1"""

UTF16 = 1
# """UTF-16 with BOM"""

UTF16BE = 2
# """UTF-16BE without BOM"""

UTF8 = 3
# """UTF-8"""
end
# Encoding=Dict(0=>"LATIN1")

const _encodings=Dict(
    LATIN1=>[0x0],
    UTF16=>[0x0,0x0],
    UTF16BE=>[0x0,0x0],
    UTF8=>[0x0],
)
const _encodings1=Dict(
    LATIN1=>"LATIN1",
    UTF16=>"UTF-16",
    UTF16BE=>"UTF-16BE",
    UTF8=>"UTF-8"
)
end