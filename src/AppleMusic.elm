module AppleMusic exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http


baseUrl : String
baseUrl =
    "https://itunes.apple.com/search"


albumDecoder : Decoder Album
albumDecoder =
    map6 Album
        (field "collectionName" string)
        (field "artistName" string)
        (field "collectionViewUrl" string)
        (field "artworkUrl60" string)
        (field "artworkUrl100" string)
        (succeed AppleMusic)


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    field "results" (list albumDecoder)


albumSearch : String -> Cmd Msg
albumSearch q =
    let
        params =
            QS.empty
                |> QS.add "country" "GB"
                |> QS.add "media" "music"
                |> QS.add "entity" "album"
                |> QS.add "term" q
                |> QS.render

        req =
            Http.get (baseUrl ++ params) albumSearchDecoder
    in
        Http.send SearchResult req
