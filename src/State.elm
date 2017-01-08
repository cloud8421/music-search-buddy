module State exposing (..)

import Types exposing (..)
import Spotify
import AppleMusic
import Album


init : ( Model, Cmd Msg )
init =
    ( { query = Nothing
      , albums = Album.emptyAlbums
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

        Search q ->
            ( { model
                | query = Just q
                , albums = Album.emptyAlbums
              }
            , search q
            )

        SearchResult provider (Ok albums) ->
            let
                newAlbums =
                    Album.addMany albums provider model.albums
            in
                ( { model | albums = newAlbums }
                , Cmd.none
                )

        SearchResult _ _ ->
            model ! []
