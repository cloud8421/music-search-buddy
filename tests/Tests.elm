module Tests exposing (..)

import Test exposing (..)
import Tests.AlbumTests
import Tests.SpotifyTests


all : Test
all =
    describe "Music search test suite"
        [ Tests.AlbumTests.all
        , Tests.SpotifyTests.all
        ]
