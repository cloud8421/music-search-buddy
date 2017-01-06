module State exposing (..)

import Types exposing (..)
import Spotify


init : ( Model, Cmd Msg )
init =
    ( { query = Nothing
      , albums = []
      }
    , Spotify.albumSearch "blackfield"
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Search q ->
            model ! [ Spotify.albumSearch q ]

        SearchResult (Ok albums) ->
            ( { model | albums = albums }
            , Cmd.none
            )

        SearchResult _ ->
            model ! []
