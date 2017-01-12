module State exposing (..)

import Types exposing (..)
import Debounce
import Spotify
import AppleMusic
import Album
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
                resourceStatus =
                    if String.length q >= 3 then
                        Loading
                    else
                        NotAsked

                newModel =
                    { model
                        | query = Just q
                        , albums = resourceStatus
                    }
            in
                update (DebounceMsg (Debounce.Bounce (search q))) newModel

        SearchResult (Success albums) ->
            let
                currentAlbums =
                    case model.albums of
                        Success albums ->
                            albums

                        otherwise ->
                            Album.empty

                newAlbums =
                    Album.addMany albums currentAlbums
            in
                ( { model
                    | albums = Success newAlbums
                  }
                , Cmd.none
                )

        SearchResult _ ->
            model ! []
