module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Types exposing (..)
import Album


spotifyBlackFieldAlbum : Album
spotifyBlackFieldAlbum =
    { artist = "Blackfield"
    , cover = "https://i.scdn.co/image/64ff3b770e913ffee89e46d1310e9fc9900054ed"
    , provider = Spotify
    , thumb = "https://i.scdn.co/image/e4d8e9ad4fa005f5fdda84f008880cb4fb85facd"
    , title = "Blackfield"
    , url = "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC"
    }


appleMusicBlackfieldAlbum : Album
appleMusicBlackfieldAlbum =
    { artist = "Blackfield"
    , cover = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/100x100bb.jpg"
    , provider = AppleMusic
    , thumb = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/60x60bb.jpg"
    , title = "Blackfield"
    , url = "https://itunes.apple.com/gb/album/blackfield/id416772823?uo=4"
    }


all : Test
all =
    describe "Music search test suite"
        [ describe "Album"
            [ test "Spotify album checksum" <|
                \() ->
                    Expect.equal 2031879720 (Album.hash spotifyBlackFieldAlbum)
            , test "Apple Music album checksum" <|
                \() ->
                    Expect.equal 2031879720 (Album.hash appleMusicBlackfieldAlbum)
            , test "Same checksum" <|
                \() ->
                    Expect.equal (Album.hash spotifyBlackFieldAlbum) (Album.hash appleMusicBlackfieldAlbum)
            ]
        ]
