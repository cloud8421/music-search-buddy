module Album exposing (..)

import FNV
import Types exposing (..)
import Dict
import String.Extra exposing (dasherize)
import String exposing (toLower)
import StringDistance


hasAppleMusicLink : Album -> Bool
hasAppleMusicLink album =
    let
        predicate provider =
            case provider of
                AppleMusic _ ->
                    True

                otherwise ->
                    False
    in
        List.any predicate album.providers


hasSpotifyLink : Album -> Bool
hasSpotifyLink album =
    let
        predicate provider =
            case provider of
                Spotify _ ->
                    True

                otherwise ->
                    False
    in
        List.any predicate album.providers


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
    case Dict.get album.id initial of
        Just existing ->
            let
                newProviders =
                    existing.providers ++ album.providers

                merged =
                    { existing | providers = newProviders }
            in
                Dict.insert existing.id merged initial

        Nothing ->
            Dict.insert album.id album initial


addMany : List Album -> Albums -> Albums
addMany idPairs initial =
    List.foldl add initial idPairs


compareWithQuery : String -> Album -> Float
compareWithQuery query album =
    StringDistance.sift3Distance (toLower album.title) (toLower query)


forProvider : ProviderFilter -> List ( Int, Album ) -> List ( Int, Album )
forProvider providerFilter albumList =
    case providerFilter of
        All ->
            albumList

        OnlySpotify ->
            albumList
                |> List.filter (\( id, album ) -> hasSpotifyLink album)

        OnlyAppleMusic ->
            albumList
                |> List.filter (\( id, album ) -> hasAppleMusicLink album)


toList : Albums -> List ( Int, Album )
toList =
    Dict.toList


sortedList : Maybe String -> List ( Int, Album ) -> List ( Int, Album )
sortedList maybeQuery albumList =
    let
        sortFn query ( id, album ) =
            compareWithQuery query album
    in
        case maybeQuery of
            Just query ->
                List.sortBy (sortFn query) albumList

            Nothing ->
                albumList
