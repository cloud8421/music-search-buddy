module AppleMusic exposing (..)

import Album
import Country
import Date exposing (Date)
import Http
import Json.Decode exposing (..)
import QueryString as QS
import Regex
import RemoteData
import Types exposing (..)


type LookupResult
    = AlbumDetailsLookup AlbumDetails
    | TrackLookup Track


customDecoder : Decoder a -> (a -> Result String b) -> Decoder b
customDecoder d f =
    let
        resultDecoder x =
            case x of
                Ok a ->
                    succeed a

                Err e ->
                    fail e
    in
        map f d |> andThen resultDecoder


dateDecoder : Decoder Date
dateDecoder =
    customDecoder string Date.fromString


thumbTransformer : String -> String
thumbTransformer url =
    Regex.replace Regex.All (Regex.regex "60x60") (\_ -> "58x58") url


coverTransformer : String -> String
coverTransformer url =
    Regex.replace Regex.All (Regex.regex "100x100") (\_ -> "178x178") url


hashDecoder : Decoder Int
hashDecoder =
    map2 Album.hash
        (field "artistName" string)
        (field "collectionName" string)


providerTransformer : Int -> List ( Provider, Id )
providerTransformer id =
    [ ( AppleMusic, (toString id) ) ]


albumDecoder : Decoder Album
albumDecoder =
    map7 Album
        hashDecoder
        (field "collectionName" string)
        (field "artistName" string)
        (field "artworkUrl60" (map thumbTransformer string))
        (field "artworkUrl100" (map coverTransformer string))
        (maybe (field "collectionPrice" float))
        (field "collectionId" (map providerTransformer int))


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    field "results" (list albumDecoder)


trackDecoder : Decoder Track
trackDecoder =
    map6 Track
        (map toString (field "trackId" int))
        (field "trackName" string)
        (field "trackTimeMillis" float)
        (field "trackNumber" int)
        (field "discNumber" int)
        (field "trackViewUrl" string)


albumDetailsDecoder : Decoder AlbumDetails
albumDetailsDecoder =
    map7 AlbumDetails
        (map toString (field "collectionId" int))
        (field "artistName" string)
        (field "collectionName" string)
        (field "releaseDate" dateDecoder)
        (field "artworkUrl100" (map coverTransformer string))
        (field "collectionViewUrl" string)
        (succeed [])


albumSearch : String -> Country -> Cmd Msg
albumSearch q country =
    let
        baseUrl =
            "https://ms-api.fullyforged.com/search/apple-music"

        params =
            QS.empty
                |> QS.add "country" (Country.toString country)
                |> QS.add "media" "music"
                |> QS.add "entity" "album"
                |> QS.add "term" q
                |> QS.render

        filterOutLegacyAlbums albums =
            List.filter (\a -> not (a.price == Nothing)) albums
    in
        Http.get (baseUrl ++ params) albumSearchDecoder
            |> RemoteData.sendRequest
            |> Cmd.map (RemoteData.map filterOutLegacyAlbums)
            |> Cmd.map SearchResult


albumDetails : String -> Country -> Cmd Msg
albumDetails albumId country =
    let
        baseUrl =
            "https://ms-api.fullyforged.com/lookup/apple-music"

        params =
            QS.empty
                |> QS.add "id" albumId
                |> QS.add "entity" "song"
                |> QS.add "country" (Country.toString country)
                |> QS.render

        itemDecoder =
            oneOf
                [ map TrackLookup trackDecoder
                , map AlbumDetailsLookup albumDetailsDecoder
                ]

        resultsDecoder =
            map2 (,)
                (field "results" (index 0 albumDetailsDecoder))
                (field "results" (list itemDecoder))

        lookupResultsComposer ( albumDetails, items ) =
            let
                foldFn current acc =
                    case current of
                        TrackLookup track ->
                            track :: acc

                        _ ->
                            acc

                tracks =
                    List.foldl foldFn [] items
            in
                { albumDetails | tracks = tracks }
    in
        Http.get (baseUrl ++ params) resultsDecoder
            |> RemoteData.sendRequest
            |> Cmd.map (RemoteData.map lookupResultsComposer)
            |> Cmd.map AlbumDetailsResult
