module Country exposing (..)

import Types exposing (..)


toString : Country -> String
toString country =
    case country of
        GB ->
            "GB"

        US ->
            "US"


fromString : String -> Result String Country
fromString countryStr =
    case countryStr of
        "GB" ->
            Ok GB

        "US" ->
            Ok US

        _ ->
            Err "Unsupported country code"


all : List Country
all =
    [ GB, US ]


default : Country
default =
    GB
