## Overview
Read ID3 from music file for Julia
## Installation

```julia-repl
(@v1.9) pkg> add https://github.com/xing8star/ID3v2.jl
```

## Example
```julia
using ID3v2
m=MPG123("yourmusic.mp3")
save(m)
```


