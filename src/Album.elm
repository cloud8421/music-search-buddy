module Album exposing (..)

import FNV
import Types exposing (..)
import Dict
import String.Extra exposing (dasherize)
import String exposing (toLower)
import StringDistance


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
        |> asList
        |> List.map mapFn


compareWithQuery : String -> Album -> Float
compareWithQuery query album =
    StringDistance.sift3Distance (toLower album.title) (toLower query)


sortedList : String -> Albums -> AlbumList
sortedList query albums =
    let
        sortFn query ( id, album ) =
            compareWithQuery query album
    in
        albums
            |> asList
            |> List.sortBy (sortFn query)


asList : Albums -> AlbumList
asList =
    Dict.toList
