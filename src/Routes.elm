module Routes exposing (..)

import Route exposing (..)
import Types exposing (..)


home : Route.Route Types.Route
home =
    HomeR := static ""


search : Route.Route Types.Route
search =
    SearchR := static "search" </> string


routes : Router Types.Route
routes =
    router [ home, search ]


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

        NotFoundR ->
            Debug.crash "cannot route to NotFound"
