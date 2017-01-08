module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (..)
import Album


albumItem : Album -> Html Msg
albumItem album =
    li []
        [ img [ src album.cover ] []
        , p [] [ text album.artist ]
        , p [] [ text album.title ]
        ]


albumList : List Album -> Html Msg
albumList albums =
    ul []
        (List.map albumItem albums)


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
            [ albumList (Album.getAlbums model.albums) ]
        ]
