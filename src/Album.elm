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


add : Album -> Albums -> Albums
add album initial =
    if Dict.member album.id initial then
        initial
    else
        Dict.insert album.id album initial


addMany : List Album -> Albums -> Albums
addMany idPairs initial =
    List.foldl add initial idPairs


compareWithQuery : String -> Album -> Float
compareWithQuery query album =
    StringDistance.sift3Distance (toLower album.title) (toLower query)


sortedList : Maybe String -> Albums -> List ( Int, Album )
sortedList maybeQuery albums =
    let
        sortFn query ( id, album ) =
            compareWithQuery query album

        albumList =
            albums
                |> Dict.toList
    in
        case maybeQuery of
            Just query ->
                List.sortBy (sortFn query) albumList

            Nothing ->
                albumList
