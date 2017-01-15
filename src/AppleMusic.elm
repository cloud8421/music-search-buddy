module AppleMusic exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http
import RemoteData
import Regex
import Album
import Country


baseUrl : String
baseUrl =
    "https://ms-api.fullyforged.com/apple-music/search"


thumbTransformer : String -> String
thumbTransformer url =
    Regex.replace Regex.All (Regex.regex "60x60") (\_ -> "58x58") url


coverTransformer : String -> String
coverTransformer url =
    Regex.replace Regex.All (Regex.regex "100x100") (\_ -> "178x178") url


idDecoder : Decoder Int
idDecoder =
    map2 Album.hash
        (field "artistName" string)
        (field "collectionName" string)


providerTransformer : Url -> List Provider
providerTransformer url =
    [ AppleMusic url ]


albumDecoder : Decoder Album
albumDecoder =
    map6 Album
        idDecoder
        (field "collectionName" string)
        (field "artistName" string)
        (field "artworkUrl60" (map thumbTransformer string))
        (field "artworkUrl100" (map coverTransformer string))
        (field "collectionViewUrl" (map providerTransformer string))


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    field "results" (list albumDecoder)


albumSearch : String -> Country -> Cmd Msg
albumSearch q country =
    let
        params =
            QS.empty
                |> QS.add "country" (Country.toString country)
                |> QS.add "media" "music"
                |> QS.add "entity" "album"
                |> QS.add "term" q
                |> QS.render
    in
        Http.get (baseUrl ++ params) albumSearchDecoder
            |> RemoteData.sendRequest
            |> Cmd.map SearchResult
