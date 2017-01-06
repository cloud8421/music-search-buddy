module State exposing (..)

import Types exposing (..)

init : ( Model, Cmd Msg )
init = 0 ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp -> model ! []
