module AppleMusic exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http


baseUrl : String
baseUrl =
    "https://itunes.apple.com/search"


thumbsDecoder =
    let
        thumb d url =
            map3 Thumb
                (succeed d)
                (succeed d)
                (succeed url)
    in
        map2 (\a b -> [ a, b ])
            (field "artworkUrl60" string |> andThen (thumb 60))
            (field "artworkUrl100" string |> andThen (thumb 100))


albumDecoder : Decoder Album
albumDecoder =
    map5 Album
        (field "collectionName" string)
        (field "artistName" string)
        (field "collectionViewUrl" string)
        thumbsDecoder
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
