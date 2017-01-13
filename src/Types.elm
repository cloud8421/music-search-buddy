module Types exposing (..)

import Dict exposing (Dict)
import Debounce
import RemoteData exposing (WebData)


type Country
    = GB
    | US


type alias Url =
    String


type Provider
    = Spotify Url
    | AppleMusic Url


type alias Albums =
    Dict Int Album


type alias Album =
    { id : Int
    , title : String
    , artist : String
    , thumb : String
    , cover : String
    , providers : List Provider
    }


type Msg
    = NoOp
    | DebounceMsg (Debounce.Msg Msg)
    | ChangeCountry Country
    | Search String
    | SearchResult (WebData (List Album))


type alias Model =
    { query : Maybe String
    , country : Country
    , albums : WebData Albums
    , debounce : Debounce.Model Msg
    }
