@setup_workload begin
@enum PictureType begin
# """Other"""
OTHER = 0

# """32x32 pixels 'file icon' (PNG only)"""
FILE_ICON = 1

# """Other file icon"""
OTHER_FILE_ICON = 2

# """Cover (front)"""
COVER_FRONT = 3

# """Cover (back)"""
COVER_BACK = 4

# """Leaflet page"""
LEAFLET_PAGE = 5

# """Media (e.g. label side of CD)"""
MEDIA = 6

# """Lead artist/lead performer/soloist"""
LEAD_ARTIST = 7

# """Artist/performer"""
ARTIST = 8

# """Conductor"""
CONDUCTOR = 9

# """Band/Orchestra"""
BAND = 10

# """Composer"""
COMPOSER = 11

# # """Lyricist/text writer"""
LYRICIST = 12

# # """Recording Location"""
RECORDING_LOCATION = 13

# # """During recording"""
DURING_RECORDING = 14

# # """During performance"""
DURING_PERFORMANCE = 15

# # """Movie/video screen capture"""
SCREEN_CAPTURE = 16

# # """A bright coloured fish"""
FISH = 17

# # """Illustration"""
ILLUSTRATION = 18

# # """Band/artist logotype"""
BAND_LOGOTYPE = 19

# # """Publisher/Studio logotype"""
PUBLISHER_LOGOTYPE = 20
end
end