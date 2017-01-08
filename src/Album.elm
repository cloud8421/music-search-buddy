module Album exposing (..)

import FNV
import Types exposing (..)
import Dict
import String.Extra exposing (dasherize)
import String exposing (toLower)


hash : Album -> Int
hash album =
    let
        artist =
            dasherize <| toLower album.artist

        title =
            dasherize <| toLower album.title
    in
        FNV.hashString (artist ++ title)


empty : Albums
empty =
    Dict.empty


values : Albums -> List Album
values albums =
    Dict.values albums


add : Int -> Album -> Albums -> Albums
add id album initial =
    if Dict.member id initial then
        initial
    else
        Dict.insert id album initial


addMany : List ( Int, Album ) -> Albums -> Albums
addMany idPairs initial =
    let
        reducer ( id, album ) current =
            add id album current
    in
        List.foldl reducer initial idPairs


map : (( Int, Album ) -> a) -> Albums -> List a
map mapFn albums =
    albums
        |> Dict.toList
        |> List.map mapFn
