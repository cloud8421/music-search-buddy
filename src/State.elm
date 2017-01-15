module State exposing (..)

import Types exposing (..)
import Debounce
import Spotify
import AppleMusic
import Album
import Time exposing (Time)
import Debounce
import RemoteData exposing (..)
import Country


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
      , country = Country.default
      , albums = NotAsked
      , debounce = Debounce.init
      , error = Nothing
      }
    , Cmd.none
    )


search : String -> Country -> Cmd Msg
search q country =
    if String.length q >= 3 then
        Cmd.batch
            [ Spotify.albumSearch q country
            , AppleMusic.albumSearch q country
            ]
    else
        Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ChangeCountry country ->
            let
                q =
                    Maybe.withDefault "" model.query

                resourceStatus =
                    if String.length q >= 3 then
                        Loading
                    else
                        NotAsked
            in
                ( { model
                    | country = country
                    , albums = resourceStatus
                    , error = Nothing
                  }
                , search q country
                )

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
                        , error = Nothing
                    }
            in
                update (DebounceMsg (Debounce.Bounce (search q newModel.country))) newModel

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

        SearchResult (Failure error) ->
            ( { model | error = Just error }
            , Cmd.none
            )

        SearchResult _ ->
            model ! []
