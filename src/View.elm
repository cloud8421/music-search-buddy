module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (..)
import Album
import Provider
import RemoteData exposing (..)


providersBadge : List ( Provider, Url ) -> Html Msg
providersBadge providers =
    let
        badge provider =
            case provider of
                ( Spotify, url ) ->
                    a [ href url ] [ text "Spotify" ]

                ( AppleMusic, url ) ->
                    a [ href url ] [ text "Apple Music" ]
    in
        span [] (List.map badge providers)


albumItem : Providers -> ( Int, Album ) -> Html Msg
albumItem providers ( id, album ) =
    let
        badge =
            case Provider.find id providers of
                Just values ->
                    providersBadge values

                Nothing ->
                    b [] [ text "No providers" ]
    in
        li []
            [ img [ src album.cover ] []
            , p [] [ text album.artist ]
            , p [] [ text album.title ]
            , p [] [ badge ]
            ]


albumList : List ( Int, Album ) -> Providers -> Html Msg
albumList albums providers =
    ul []
        (List.map (albumItem providers) albums)


searchBox : Maybe String -> Html Msg
searchBox q =
    input
        [ type_ "search"
        , id "q"
        , name "q"
        , onInput Search
        , value (Maybe.withDefault "" q)
        , placeholder "e.g. Porcupine Tree"
        ]
        []


root : Model -> Html Msg
root model =
    let
        searchData =
            RemoteData.map (,) model.albums
                |> RemoteData.andMap model.providers

        albumsSection =
            case searchData of
                Success ( albums, providers ) ->
                    let
                        sortedAlbums =
                            case model.query of
                                Nothing ->
                                    Album.asList albums

                                Just query ->
                                    Album.sortedList query albums
                    in
                        albumList sortedAlbums providers

                Loading ->
                    h1 [] [ text "stuff is loading" ]

                NotAsked ->
                    h1 [] [ text "search something" ]

                Failure e ->
                    h1 [] [ text <| toString e ]
    in
        main_ []
            [ nav [] [ searchBox model.query ]
            , section [ class "albums" ]
                [ albumsSection ]
            ]
