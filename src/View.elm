module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (..)
import Album


providersBadge : List Provider -> Html Msg
providersBadge providers =
    let
        badge provider =
            case provider of
                Spotify ->
                    b [] [ text "Spotify" ]

                AppleMusic ->
                    b [] [ text "Apple Music" ]
    in
        span [] (List.map badge providers)


albumItem : ( Album, List Provider ) -> Html Msg
albumItem ( album, providers ) =
    li []
        [ img [ src album.cover ] []
        , p [] [ text album.artist ]
        , p [] [ text album.title ]
        , providersBadge providers
        ]


albumList : Albums -> Html Msg
albumList albums =
    ul []
        (List.map albumItem (Album.values albums))


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
    main_ []
        [ nav [] [ searchBox model.query ]
        , section [ class "albums" ]
            [ albumList model.albums ]
        ]
