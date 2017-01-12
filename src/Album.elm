module Album exposing (..)

import FNV
import Types exposing (..)
import Dict
import String.Extra exposing (dasherize)
import String exposing (toLower)
import StringDistance


hash : String -> String -> Int
hash artist title =
    let
        normalizedArtist =
            dasherize <| toLower artist

        normalizedTitle =
            dasherize <| toLower title
    in
        FNV.hashString (normalizedArtist ++ normalizedTitle)


empty : Albums
empty =
    Dict.empty


values : Albums -> List Album
values albums =
    Dict.values albums


add : Album -> Albums -> Albums
add album initial =
    if Dict.member album.id initial then
        initial
    else
        Dict.insert album.id album initial


addMany : List Album -> Albums -> Albums
addMany idPairs initial =
    List.foldl add initial idPairs


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
