module Tests exposing (..)

import Test exposing (..)
import Tests.AlbumTests
import Tests.SpotifyTests
import Tests.AppleMusicTests


all : Test
all =
    describe "Music search test suite"
        [ Tests.AlbumTests.all
        , Tests.SpotifyTests.all
        , Tests.AppleMusicTests.all
        ]
