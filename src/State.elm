module State exposing (..)

import Types exposing (..)
import Debounce
import Spotify
import AppleMusic
import Album
import Provider
import Time exposing (Time)
import Debounce
import RemoteData exposing (..)


searchDebounce : Time
searchDebounce =
    500 * Time.millisecond


mapDebounceResult : Cmd (Result (Debounce.Msg Msg) Msg) -> Cmd Msg
mapDebounceResult result =
    Cmd.map
        (\r ->
            case r of
                Err a_ ->
                    DebounceMsg a_

                Ok a_ ->
                    a_
        )
        result


init : ( Model, Cmd Msg )
init =
    ( { query = Nothing
      , albums = NotAsked
      , providers = NotAsked
      , debounce = Debounce.init
      }
    , Cmd.none
    )


search : String -> Cmd Msg
search q =
    if String.length q >= 3 then
        Cmd.batch
            [ Spotify.albumSearch q
            , AppleMusic.albumSearch q
            ]
    else
        Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        DebounceMsg a ->
            let
                ( newDebounce, result ) =
                    Debounce.update searchDebounce a model.debounce

                newModel =
                    { model | debounce = newDebounce }
            in
                newModel
                    ! [ mapDebounceResult result ]

        Search q ->
            let
                newModel =
                    { model
                        | query = Just q
                        , albums = Loading
                    }
            in
                update (DebounceMsg (Debounce.Bounce (search q))) newModel

        SearchResult provider (Success albums) ->
            let
                providerTriplets =
                    List.map (\a -> ( Album.hash a, provider, a.url )) albums

                albumPairs =
                    List.map (\a -> ( Album.hash a, a )) albums

                currentAlbums =
                    case model.albums of
                        Success albums ->
                            albums

                        otherwise ->
                            Album.empty

                newAlbums =
                    Album.addMany albumPairs currentAlbums

                currentProviders =
                    case model.providers of
                        Success providers ->
                            providers

                        otherwise ->
                            Provider.empty

                newProviders =
                    Provider.addMany providerTriplets currentProviders
            in
                ( { model
                    | albums = Success newAlbums
                    , providers = Success newProviders
                  }
                , Cmd.none
                )

        SearchResult _ _ ->
            model ! []
