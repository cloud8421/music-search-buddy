module State exposing (..)

import Types exposing (..)
import Spotify
import AppleMusic
import Album
import Provider


init : ( Model, Cmd Msg )
init =
    ( { query = Nothing
      , albums = Album.empty
      , providers = Provider.empty
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
                , albums = Album.empty
              }
            , search q
            )

        SearchResult provider (Ok albums) ->
            let
                ids =
                    List.map Album.hash albums

                providerPairs =
                    List.map (\id -> ( id, provider )) ids

                albumPairs =
                    List.map2 (,) ids albums

                newAlbums =
                    Album.addMany albumPairs model.albums

                newProviders =
                    Provider.addMany providerPairs model.providers
            in
                ( { model
                    | albums = newAlbums
                    , providers = newProviders
                  }
                , Cmd.none
                )

        SearchResult _ _ ->
            model ! []
