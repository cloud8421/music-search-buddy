module State exposing (..)

import Album
import AppleMusic
import Country
import Debounce
import Http
import Navigation
import RemoteData exposing (..)
import Routes
import Spotify
import Time exposing (Time)
import Types exposing (..)


searchDebounce : Time
searchDebounce =
    500 * Time.millisecond


mapDebounceResult : Cmd (Result (Debounce.Msg Msg) Msg) -> Cmd Msg
mapDebounceResult result =
    let
        valOrDebounce r =
            case r of
                Err a_ ->
                    DebounceMsg a_

                Ok a_ ->
                    a_
    in
        Cmd.map valOrDebounce result


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            Routes.match location.pathname
                |> Maybe.withDefault NotFoundR

        model =
            { route = route
            , query = Nothing
            , providerFilter = All
            , country = Country.default
            , albums = NotAsked
            , debounce = Debounce.init
            , error = Nothing
            }
    in
        update (GoTo route) model


search : String -> Country -> Cmd Msg
search q country =
    if String.length q >= 3 then
        Cmd.batch
            [ Spotify.albumSearch q country
            , AppleMusic.albumSearch q country
            ]
    else
        Cmd.none


updateRoute : Route -> Model -> ( Model, Cmd Msg )
updateRoute route model =
    case route of
        HomeR ->
            ( { model
                | route = route
                , query = Nothing
                , providerFilter = All
                , error = Nothing
                , albums = NotAsked
              }
            , Navigation.newUrl (Routes.toString route)
            )

        SearchR encoded ->
            let
                decoded =
                    Http.decodeUri encoded
            in
                ( { model
                    | route = route
                    , providerFilter = All
                    , query = decoded
                    , error = Nothing
                    , albums = Loading
                  }
                , Cmd.batch
                    [ search (Maybe.withDefault "" decoded) model.country
                    , Navigation.newUrl (Routes.toString route)
                    ]
                )

        otherwise ->
            ( { model | route = route }
            , Navigation.newUrl (Routes.toString route)
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        UrlChange location ->
            let
                route =
                    Routes.match location.pathname
                        |> Maybe.withDefault NotFoundR
            in
                ( { model | route = route }
                , Cmd.none
                )

        GoTo route ->
            updateRoute route model

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

                route =
                    if String.length q >= 3 then
                        SearchR q
                    else
                        HomeR

                newModel =
                    { model
                        | query = Just q
                        , albums = resourceStatus
                        , error = Nothing
                    }

                cmd =
                    Cmd.batch
                        [ Navigation.newUrl (Routes.toString route)
                        , search q model.country
                        ]
            in
                update (DebounceMsg (Debounce.Bounce cmd)) newModel

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

        SetProviderFilter providerFilter ->
            ( { model | providerFilter = providerFilter }
            , Cmd.none
            )
