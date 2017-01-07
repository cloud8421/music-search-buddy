module Types exposing (..)

import Http


type Msg
    = NoOp
    | Search String
    | SearchResult (Result Http.Error (List Album))


type alias Model =
    { query : Maybe String
    , albums : List Album
    }


type Provider
    = Spotify
    | ITunes


type alias Album =
    { title : String
    , artist : String
    , url : String
    , thumb : String
    , cover : String
    , provider : Provider
    }
