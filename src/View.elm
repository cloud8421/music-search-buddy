module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, targetValue)
import Types exposing (..)
import Album
import RemoteData exposing (..)
import Country
import Json.Decode as Json
import String.Extra exposing (ellipsis)


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


providersBadge : List Provider -> Html Msg
providersBadge providers =
    let
        badge provider =
            case provider of
                Spotify url ->
                    a [ href url ] [ i [ class "fa fa-spotify" ] [] ]

                AppleMusic url ->
                    a [ href url ] [ i [ class "fa fa-apple" ] [] ]
    in
        span [ class "links" ] (List.map badge providers)


albumItem : ( Int, Album ) -> Html Msg
albumItem ( id, album ) =
    li []
        [ figure []
            [ img [ src album.cover ] []
            , figcaption []
                [ providersBadge album.providers
                , section [ class "meta" ]
                    [ p [ class "artist" ] [ text <| ellipsis 32 album.artist ]
                    , p [ class "title" ] [ text <| ellipsis 64 album.title ]
                    ]
                ]
            ]
        ]


albumList : List ( Int, Album ) -> Html Msg
albumList albums =
    case albums of
        [] ->
            div [ class "no-results" ]
                [ i [ class "fa fa-frown-o background-icon" ] []
                , p []
                    [ text "Sorry! No results for this search"
                    ]
                ]

        otherwise ->
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


customDecoder : Json.Decoder a -> (a -> Result String b) -> Json.Decoder b
customDecoder d f =
    let
        resultDecoder x =
            case x of
                Ok a ->
                    Json.succeed a

                Err e ->
                    Json.fail e
    in
        Json.map f d |> Json.andThen resultDecoder


onCountryChange : (Country -> Msg) -> Attribute Msg
onCountryChange msg =
    let
        decoder =
            (customDecoder targetValue Country.fromString)
                |> Json.map msg
    in
        on "change" decoder


countryOptions : Country -> List (Html Msg)
countryOptions selectedCountry =
    let
        opt country =
            option
                [ name <| Country.toString country
                , value <| Country.toString country
                , selected (country == selectedCountry)
                ]
                [ text <| Country.toString country ]
    in
        List.map opt Country.all


countrySelect : Country -> Html Msg
countrySelect currentCountry =
    select
        [ onCountryChange ChangeCountry
        ]
        (countryOptions currentCountry)


errorAlert : Html Msg
errorAlert =
    section [ class "errors" ]
        [ p []
            [ text "Aw snap! There was an error with the search. Please try again."
            ]
        ]


searchNav : Model -> Html Msg
searchNav model =
    nav []
        [ i [ class "fa fa-search" ] []
        , searchBox model.query
        , countrySelect model.country
        ]


albumsSection : Model -> Html Msg
albumsSection model =
    let
        contents =
            case model.albums of
                Success albums ->
                    let
                        sortedAlbums =
                            Album.sortedList model.query albums
                    in
                        albumList sortedAlbums

                Loading ->
                    spinner

                NotAsked ->
                    i [ class "fa fa-music background-icon" ] []

                Failure e ->
                    h1 [] [ text <| toString e ]
    in
        section [ class "albums" ]
            [ contents ]


root : Model -> Html Msg
root model =
    case model.error of
        Just _ ->
            main_ []
                [ searchNav model
                , errorAlert
                , albumsSection model
                ]

        Nothing ->
            main_ []
                [ searchNav model
                , albumsSection model
                ]
