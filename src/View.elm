module View exposing (..)

import Album
import Country
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, targetValue, onWithOptions)
import Json.Decode as Json
import RemoteData exposing (..)
import Routes
import String.Extra exposing (ellipsis)
import Types exposing (..)


iconLink : Route -> Html Msg -> List (Attribute Msg) -> Html Msg
iconLink route icon attrs =
    let
        opts =
            { preventDefault = True
            , stopPropagation = False
            }

        defaultAttrs =
            [ href (Routes.toString route)
            , onWithOptions "click" opts (Json.succeed <| GoTo route)
            ]
    in
        a
            (defaultAttrs ++ attrs)
            [ icon ]


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


providersBadge : List ( Provider, Id ) -> Html Msg
providersBadge providers =
    let
        badge provider =
            case provider of
                ( Spotify, id ) ->
                    iconLink (LookupR Spotify id)
                        (i [ class "icon-spotify" ] [])
                        []

                ( AppleMusic, id ) ->
                    iconLink (LookupR AppleMusic id)
                        (i [ class "icon-appleinc" ] [])
                        []
    in
        span [ class "links" ] (List.map badge providers)


albumItem : ( Int, Album ) -> Html Msg
albumItem ( hash, album ) =
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


albumList : Albums -> Html Msg
albumList albums =
    case albums of
        [] ->
            div [ class "no-results" ]
                [ i [ class "icon-sad background-icon" ] []
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
        , onClick CloseAlbumDetails
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


providerFilter : Model -> Html Msg
providerFilter model =
    let
        allButton =
            span
                [ classList [ ( "active", model.providerFilter == All ) ]
                , onClick (SetProviderFilter All)
                ]
                [ text "All" ]

        appleMusicButton =
            i
                [ classList
                    [ ( "icon-appleinc", True )
                    , ( "active", model.providerFilter == OnlyAppleMusic )
                    ]
                , onClick (SetProviderFilter OnlyAppleMusic)
                ]
                []

        spotifyButton =
            i
                [ classList
                    [ ( "icon-spotify", True )
                    , ( "active", model.providerFilter == OnlySpotify )
                    ]
                , onClick (SetProviderFilter OnlySpotify)
                ]
                []
    in
        p [ class "provider-filter" ]
            [ text "Show me: "
            , allButton
            , text " | "
            , appleMusicButton
            , text " | "
            , spotifyButton
            ]


searchNav : Model -> Html Msg
searchNav model =
    Html.form [ id "search" ]
        [ i [ class "icon-search" ] []
        , searchBox model.query
        , countrySelect model.country
        , providerFilter model
        ]


albumsSection : Model -> Html Msg
albumsSection model =
    let
        contents =
            case model.albums of
                Success albums ->
                    albums
                        |> Album.forProvider model.providerFilter
                        |> albumList

                Loading ->
                    spinner

                NotAsked ->
                    i [ class "icon-music background-icon" ] []

                Failure e ->
                    h1 [] [ text <| toString e ]
    in
        section [ class "albums" ]
            [ contents ]


trackList : List Track -> Html Msg
trackList tracks =
    let
        formatDuration duration =
            let
                minutes =
                    truncate (duration / 1000 / 60)

                seconds =
                    rem (round (duration / 1000)) 60

                pad s =
                    if String.length s <= 1 then
                        "0" ++ s
                    else
                        s
            in
                (minutes |> toString) ++ ":" ++ (seconds |> toString |> pad)

        row track =
            li []
                [ a
                    [ class "play"
                    , href track.url
                    ]
                    [ i [ class "icon-play2" ] [] ]
                , span [ class "number" ] [ text <| toString track.number ]
                , span [ class "title" ] [ text track.title ]
                , span [ class "duration" ] [ text <| formatDuration track.duration ]
                ]

        orderedTracks =
            List.sortBy .number tracks

        totalDuration =
            tracks
                |> List.map .duration
                |> List.foldl (+) 0

        totalDurationRow =
            li []
                [ span [ class "title" ] [ text "Total" ]
                , span [ class "duration" ] [ text <| formatDuration totalDuration ]
                ]
    in
        ul [ class "track-list" ]
            ((List.map row orderedTracks) ++ [ totalDurationRow ])


albumDetailsPreview : Model -> Html Msg
albumDetailsPreview model =
    case model.currentAlbum of
        Success albumDetails ->
            div [ class "album-details" ]
                [ div [ class "container" ]
                    [ i
                        [ class "icon-cancel-circle"
                        , onClick CloseAlbumDetails
                        ]
                        []
                    , h1 []
                        [ text albumDetails.title ]
                    , h2 [] [ text albumDetails.artist ]
                    , section [ class "tracks" ]
                        [ figure []
                            [ a [ href albumDetails.url ]
                                [ i [ class "icon-play2" ] []
                                , img [ src albumDetails.cover ] []
                                ]
                            , figcaption []
                                [ p [] [ text <| toString <| Date.year albumDetails.releaseDate ]
                                ]
                            ]
                        , trackList albumDetails.tracks
                        ]
                    ]
                ]

        Loading ->
            div [ class "album-details" ]
                [ div [ class "container" ]
                    [ spinner ]
                ]

        otherwise ->
            div [] []


mainFooter : Html Msg
mainFooter =
    footer []
        [ p [ class "primary" ]
            [ text "Made by Claudio Ortolina" ]
        , p [ class "secondary" ]
            [ text "Contact me on "
            , a [ href "https://twitter.com/cloud8421" ]
                [ i [ class "icon-twitter" ] []
                , text " Twitter"
                ]
            , text " | Source available on "
            , a [ href "https://github.com/cloud8421/music-search-buddy" ]
                [ i [ class "icon-github" ] []
                , text " GitHub"
                ]
            ]
        , p [ class "secondary" ]
            [ text "Icon credit: "
            , a [ href "http://dtafalonso.deviantart.com/art/Yosemite-Flat-Icons-503499921" ]
                [ text "Yosemite Flat Icons pack by Enrique Alonso Ramírez Tejeda"
                ]
            ]
        , p [ class "secondary" ]
            [ text "Icon font by "
            , a [ href "http://icomoon.io" ]
                [ text "Icomoon" ]
            ]
        ]


root : Model -> Html Msg
root model =
    case model.error of
        Just _ ->
            main_ []
                [ searchNav model
                , errorAlert
                , albumsSection model
                , albumDetailsPreview model
                , mainFooter
                ]

        Nothing ->
            main_ []
                [ searchNav model
                , albumsSection model
                , albumDetailsPreview model
                , mainFooter
                ]
