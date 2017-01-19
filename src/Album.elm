module Album exposing (..)

import Dict
import FNV
import String exposing (toLower)
import String.Extra exposing (dasherize)
import StringDistance
import Types exposing (..)


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
    case Dict.get album.hash initial of
        Just existing ->
            let
                newProviders =
                    existing.providers ++ album.providers

                merged =
                    { existing | providers = newProviders }
            in
                Dict.insert existing.hash merged initial

        Nothing ->
            Dict.insert album.hash album initial


addMany : List Album -> Albums -> Albums
addMany hashPairs initial =
    List.foldl add initial hashPairs


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
                |> List.filter (\( hash, album ) -> hasSpotifyLink album)

        OnlyAppleMusic ->
            albumList
                |> List.filter (\( hash, album ) -> hasAppleMusicLink album)


toList : Albums -> List ( Int, Album )
toList =
    Dict.toList


sortedList : Maybe String -> List ( Int, Album ) -> List ( Int, Album )
sortedList maybeQuery albumList =
    let
        sortFn query ( hash, album ) =
            compareWithQuery query album
    in
        case maybeQuery of
            Just query ->
                List.sortBy (sortFn query) albumList

            Nothing ->
                albumList
