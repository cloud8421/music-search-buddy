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


type alias Thumb =
    { width : Int
    , height : Int
    , url : String
    }


type alias Album =
    { title : String
    , artist : String
    , url : String
    , thumbs : List Thumb
    , provider : Provider
    }
