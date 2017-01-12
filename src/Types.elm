module Types exposing (..)

import Dict exposing (Dict)
import Debounce
import RemoteData exposing (WebData)


type alias Url =
    String


type Provider
    = Spotify
    | AppleMusic


type alias Providers =
    Dict Int (List ( Provider, Url ))


type alias Albums =
    Dict Int Album


type alias Album =
    { id : Int
    , title : String
    , artist : String
    , url : String
    , thumb : String
    , cover : String
    }


type Msg
    = NoOp
    | DebounceMsg (Debounce.Msg Msg)
    | Search String
    | SearchResult Provider (WebData (List Album))


type alias Model =
    { query : Maybe String
    , albums : WebData Albums
    , providers : WebData Providers
    , debounce : Debounce.Model Msg
    }
