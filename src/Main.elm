module Main exposing (..)

import Platform.Sub as Sub
import Types exposing (..)
import State
import View
import Navigation


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
