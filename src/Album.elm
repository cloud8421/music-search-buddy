module Album exposing (..)

import FNV
import Types exposing (..)
import Dict


hash : Album -> Int
hash album =
    FNV.hashString (album.artist ++ album.title)


emptyAlbums : Albums
emptyAlbums =
    Dict.empty


values : Albums -> List ( Album, List Provider )
values albums =
    Dict.values albums


add : Albums -> Album -> Provider -> Albums
add albums album provider =
    let
        id =
            hash album

        entry =
            case Dict.get id albums of
                Just ( existing, providers ) ->
                    ( existing, provider :: providers )

                Nothing ->
                    ( album, [ provider ] )
    in
        Dict.insert id entry albums


addMany : List Album -> Provider -> Albums -> Albums
addMany results provider albums =
    let
        reducer album current =
            add current album provider
    in
        List.foldl reducer albums results
