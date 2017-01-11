module Tests exposing (..)

import Test exposing (..)
import Tests.AlbumTests


all : Test
all =
    describe "Music search test suite"
        [ Tests.AlbumTests.all
        ]
