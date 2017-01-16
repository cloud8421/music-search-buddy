module Types exposing (..)

import Dict exposing (Dict)
import Debounce
import RemoteData exposing (WebData)
import Http exposing (Error)
import Navigation exposing (Location)


type Route
    = HomeR
    | SearchR String
    | NotFoundR


type Country
    = GB
    | US


type alias Url =
    String


type Provider
    = Spotify Url
    | AppleMusic Url


type ProviderFilter
    = All
    | OnlySpotify
    | OnlyAppleMusic


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
    | UrlChange Location
    | GoTo Route
    | DebounceMsg (Debounce.Msg Msg)
    | ChangeCountry Country
    | Search String
    | SearchResult (WebData (List Album))
    | SetProviderFilter ProviderFilter


type alias Model =
    { route : Route
    , query : Maybe String
    , providerFilter : ProviderFilter
    , country : Country
    , albums : WebData Albums
    , debounce : Debounce.Model Msg
    , error : Maybe Error
    }
