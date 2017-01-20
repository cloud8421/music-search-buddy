module Types exposing (..)

import Debounce
import Dict exposing (Dict)
import Http exposing (Error)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Route
    = HomeR
    | SearchR String
    | LookupR Provider String
    | NotFoundR


type Country
    = GB
    | US


type alias Id =
    String


type Provider
    = Spotify
    | AppleMusic


type ProviderFilter
    = All
    | OnlySpotify
    | OnlyAppleMusic


type alias Albums =
    Dict Int Album


type alias Album =
    { hash : Int
    , title : String
    , artist : String
    , thumb : String
    , cover : String
    , price : Maybe Float
    , providers : List ( Provider, Id )
    }


type alias Track =
    { id : String
    , title : String
    , duration : Int
    , number : Int
    , disc : Int
    , url : String
    }


type alias AlbumDetails =
    { id : String
    , artist : String
    , title : String
    , releaseDate : String
    , tracks : List Track
    }


type Msg
    = NoOp
    | UrlChange Location
    | GoTo Route
    | DebounceMsg (Debounce.Msg Msg)
    | ChangeCountry Country
    | Search String
    | SearchResult (WebData (List Album))
    | AlbumDetailsResult (WebData AlbumDetails)
    | CloseAlbumDetails
    | SetProviderFilter ProviderFilter


type alias Model =
    { route : Route
    , query : Maybe String
    , providerFilter : ProviderFilter
    , country : Country
    , albums : WebData Albums
    , currentAlbum : WebData AlbumDetails
    , debounce : Debounce.Model Msg
    , error : Maybe Error
    }
