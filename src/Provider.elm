module Provider exposing (..)

import Dict exposing (Dict)
import Types exposing (..)


empty : Providers
empty =
    Dict.empty


add : Int -> Provider -> Url -> Providers -> Providers
add id provider url initial =
    case Dict.get id initial of
        Nothing ->
            Dict.insert id [ ( provider, url ) ] initial

        Just existing ->
            Dict.insert id (merge ( provider, url ) existing) initial


addMany : List ( Int, Provider, Url ) -> Providers -> Providers
addMany idPairs initial =
    let
        reducer ( id, provider, url ) current =
            add id provider url current
    in
        List.foldl reducer initial idPairs


merge : ( Provider, Url ) -> List ( Provider, Url ) -> List ( Provider, Url )
merge providerUrl providers =
    if List.member providerUrl providers then
        providers
    else
        providerUrl :: providers


find : Int -> Providers -> Maybe (List ( Provider, Url ))
find id providers =
    Dict.get id providers
