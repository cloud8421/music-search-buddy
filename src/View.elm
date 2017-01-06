module View exposing (..)

import Html exposing (div, text, Html)
import Types exposing (..)


root : Model -> Html Msg
root model =
    div []
        [ model |> toString |> text ]
