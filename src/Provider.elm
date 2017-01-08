module Provider exposing (..)

import Dict exposing (Dict)
import Types exposing (..)


empty : Providers
empty =
    Dict.empty


add : Int -> Provider -> Providers -> Providers
add id provider initial =
    case Dict.get id initial of
        Nothing ->
            Dict.insert id [ provider ] initial

        Just existing ->
            Dict.insert id (merge provider existing) initial


addMany : List ( Int, Provider ) -> Providers -> Providers
addMany idPairs initial =
    let
        reducer ( id, provider ) current =
            add id provider current
    in
        List.foldl reducer initial idPairs


merge : Provider -> List Provider -> List Provider
merge provider providers =
    if List.member provider providers then
        providers
    else
        provider :: providers


find : Int -> Providers -> Maybe (List Provider)
find id providers =
    Dict.get id providers
