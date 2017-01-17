module Main exposing (..)

import Navigation
import Platform.Sub as Sub
import State
import Types exposing (..)
import View


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = State.init
        , view = View.root
        , update = State.update
        , subscriptions = subscriptions
        }
