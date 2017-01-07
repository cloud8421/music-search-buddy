module Spotify exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http


baseUrl : String
baseUrl =
    "https://ff-ms-api.herokuapp.com/spotify/search"


artistDecoder : Decoder String
artistDecoder =
    index 0 (field "name" string)


imgDecoder =
    (field "url" string)


albumDecoder : Decoder Album
albumDecoder =
    map6 Album
        (field "name" string)
        (field "artists" artistDecoder)
        (at [ "external_urls", "spotify" ] string)
        (field "images" (index 2 (imgDecoder)))
        (field "images" (index 0 (imgDecoder)))
        (succeed Spotify)


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    at [ "albums", "items" ] (list albumDecoder)


albumSearch : String -> Cmd Msg
albumSearch q =
    let
        params =
            QS.empty
                |> QS.add "q" ("album:" ++ q)
                |> QS.add "type" "album"
                |> QS.render

        req =
            Http.get (baseUrl ++ params) albumSearchDecoder
    in
        Http.send SearchResult req
