module Album exposing (..)

import FNV
import Types exposing (..)


hash : Album -> Int
hash album =
    FNV.hashString (album.artist ++ album.title)
