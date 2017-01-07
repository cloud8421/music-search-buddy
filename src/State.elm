module State exposing (..)

import Types exposing (..)
import Spotify
import AppleMusic


init : ( Model, Cmd Msg )
init =
    ( { query = Nothing
      , albums = []
      }
    , Cmd.none
    )


search : String -> Cmd Msg
search q =
    if String.length q >= 3 then
        Spotify.albumSearch q
    else
        Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Search q ->
            ( { model
                | query = Just q
                , albums = []
              }
            , search q
            )

        SearchResult (Ok albums) ->
            ( { model | albums = albums }
            , Cmd.none
            )

        SearchResult _ ->
            model ! []
