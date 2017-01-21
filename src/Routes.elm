module Routes exposing (..)

import Route exposing (..)
import Types exposing (..)
import Combine exposing ((<$), choice, Parser)


providerCombinator : Parser s Provider
providerCombinator =
    choice
        [ Spotify <$ Combine.string "spotify"
        , AppleMusic <$ Combine.string "apple-music"
        ]


home : Route.Route Types.Route
home =
    HomeR := static ""


search : Route.Route Types.Route
search =
    SearchR := static "search" </> string


lookup : Route.Route Types.Route
lookup =
    LookupR := static "lookup" </> (custom providerCombinator) </> string


routes : Router Types.Route
routes =
    router [ home, search, lookup ]


match : String -> Maybe Types.Route
match =
    Route.match routes


toString : Types.Route -> String
toString route =
    case route of
        HomeR ->
            reverse home []

        SearchR query ->
            reverse search [ query ]

        LookupR provider id ->
            let
                params =
                    case provider of
                        Spotify ->
                            [ "spotify", id ]

                        AppleMusic ->
                            [ "apple-music", id ]
            in
                reverse lookup params

        NotFoundR ->
            Debug.crash "cannot route to NotFound"
