module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (..)
import Album
import Provider
import RemoteData exposing (..)


spinner : Html msg
spinner =
    div [ class "spinner" ]
        [ div [ class "rect1" ]
            []
        , div [ class "rect2" ]
            []
        , div [ class "rect3" ]
            []
        , div [ class "rect4" ]
            []
        , div [ class "rect5" ]
            []
        ]


providersBadge : List ( Provider, Url ) -> Html Msg
providersBadge providers =
    let
        badge provider =
            case provider of
                ( Spotify, url ) ->
                    a [ href url ] [ i [ class "fa fa-spotify" ] [] ]

                ( AppleMusic, url ) ->
                    a [ href url ] [ i [ class "fa fa-apple" ] [] ]
    in
        span [ class "links" ] (List.map badge providers)


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
            [ figure []
                [ img [ src album.cover ] []
                , figcaption []
                    [ badge ]
                ]
            , section [ class "meta" ]
                [ p [ class "artist" ] [ text album.artist ]
                , p [ class "title" ] [ text album.title ]
                ]
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
                            Album.sortedList model.query albums
                    in
                        albumList sortedAlbums providers

                Loading ->
                    spinner

                NotAsked ->
                    h1 [] [ text "Results will appear here" ]

                Failure e ->
                    h1 [] [ text <| toString e ]
    in
        main_ []
            [ nav []
                [ i [ class "fa fa-search" ] []
                , searchBox model.query
                ]
            , section [ class "albums" ]
                [ albumsSection ]
            ]
