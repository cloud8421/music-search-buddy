module Types exposing (..)

import Http
import Dict exposing (Dict)


type Msg
    = NoOp
    | Search String
    | SearchResult Provider (Result Http.Error (List Album))


type alias Model =
    { query : Maybe String
    , albums : Albums
    }


type Provider
    = Spotify
    | AppleMusic


type alias Albums =
    Dict Int ( Album, List Provider )


type alias Album =
    { title : String
    , artist : String
    , url : String
    , thumb : String
    , cover : String
    }
