module Spotify exposing (..)

import Album
import Country
import Http
import Json.Decode exposing (..)
import QueryString as QS
import RemoteData
import Types exposing (..)


baseUrl : String
baseUrl =
    "https://ms-api.fullyforged.com/search/spotify"


artistDecoder : Decoder String
artistDecoder =
    index 0 (field "name" string)


imgDecoder : Decoder String
imgDecoder =
    (field "url" string)


idDecoder : Decoder Int
idDecoder =
    map2 Album.hash
        (field "artists" artistDecoder)
        (field "name" string)


providerTransformer : Id -> List ( Provider, Id )
providerTransformer id =
    [ ( Spotify, id ) ]


albumDecoder : Decoder Album
albumDecoder =
    map7 Album
        idDecoder
        (field "name" string)
        (field "artists" artistDecoder)
        (field "images" (index 2 (imgDecoder)))
        (field "images" (index 1 (imgDecoder)))
        (succeed Nothing)
        (field "id" (map providerTransformer string))


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    at [ "albums", "items" ] (list albumDecoder)


trackDecoder : Decoder Track
trackDecoder =
    map6 Track
        (field "id" string)
        (field "name" string)
        (field "duration_ms" float)
        (field "track_number" int)
        (field "disc_number" int)
        (field "href" string)


albumDetailsDecoder : Decoder AlbumDetails
albumDetailsDecoder =
    map6 AlbumDetails
        (field "id" string)
        (field "artists" artistDecoder)
        (field "name" string)
        (field "release_date" string)
        (field "images" (index 1 (imgDecoder)))
        (at [ "tracks", "items" ] (list trackDecoder))


albumSearch : String -> Country -> Cmd Msg
albumSearch q country =
    let
        params =
            QS.empty
                |> QS.add "q" q
                |> QS.add "type" "album"
                |> QS.add "market" (Country.toString country)
                |> QS.render
    in
        Http.get (baseUrl ++ params) albumSearchDecoder
            |> RemoteData.sendRequest
            |> Cmd.map SearchResult


albumDetails : String -> Country -> Cmd Msg
albumDetails id country =
    let
        url =
            "https://ms-api.fullyforged.com/lookup/spotify/" ++ id
    in
        Http.get url albumDetailsDecoder
            |> RemoteData.sendRequest
            |> Cmd.map AlbumDetailsResult
