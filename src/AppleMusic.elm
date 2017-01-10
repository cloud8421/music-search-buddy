module AppleMusic exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http
import RemoteData


baseUrl : String
baseUrl =
    "https://ff-ms-api.herokuapp.com/apple-music/search"


albumDecoder : Decoder Album
albumDecoder =
    map5 Album
        (field "collectionName" string)
        (field "artistName" string)
        (field "collectionViewUrl" string)
        (field "artworkUrl60" string)
        (field "artworkUrl100" string)


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
    in
        Http.get (baseUrl ++ params) albumSearchDecoder
            |> RemoteData.sendRequest
            |> Cmd.map (SearchResult AppleMusic)
