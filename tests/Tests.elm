module Tests exposing (..)

import Test exposing (..)
import Fuzz exposing (string)
import Expect
import Types exposing (..)
import Album
import Dict


spotifyBlackFieldAlbum : Album
spotifyBlackFieldAlbum =
    { artist = "Blackfield"
    , cover = "https://i.scdn.co/image/64ff3b770e913ffee89e46d1310e9fc9900054ed"
    , thumb = "https://i.scdn.co/image/e4d8e9ad4fa005f5fdda84f008880cb4fb85facd"
    , title = "Blackfield NYC - Blackfield Live In New York City"
    , url = "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC"
    }


appleMusicBlackfieldAlbum : Album
appleMusicBlackfieldAlbum =
    { artist = "Blackfield"
    , cover = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/100x100bb.jpg"
    , thumb = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/60x60bb.jpg"
    , title = "Blackfield NYC - Blackfield Live In New York City"
    , url = "https://itunes.apple.com/gb/album/blackfield/id416772823?uo=4"
    }


newAlbum : String -> String -> Album
newAlbum randA randB =
    { artist = (randA ++ "-artist")
    , cover = ("http://example.com/" ++ randA ++ "-cover.jpg")
    , thumb = ("http://example.com/" ++ randA ++ "-thumb.jpg")
    , title = (randB ++ "-title")
    , url = ("http://example.com/" ++ randA ++ "-url.html")
    }


all : Test
all =
    describe "Music search test suite"
        [ describe "Album"
            [ fuzz2 string string "consistent hash" <|
                \a b ->
                    Expect.equal (Album.hash <| newAlbum a b) (Album.hash <| newAlbum a b)
            , test "add a new album to empty collection" <|
                \() ->
                    let
                        albums =
                            Album.add Album.emptyAlbums spotifyBlackFieldAlbum Spotify

                        id =
                            Album.hash spotifyBlackFieldAlbum

                        expected =
                            Dict.fromList [ ( id, ( spotifyBlackFieldAlbum, [ Spotify ] ) ) ]
                    in
                        Expect.equalDicts expected albums
            , test "add a duplicate album" <|
                \() ->
                    let
                        initial =
                            Album.add Album.emptyAlbums spotifyBlackFieldAlbum Spotify

                        albums =
                            Album.add initial appleMusicBlackfieldAlbum AppleMusic

                        id =
                            Album.hash spotifyBlackFieldAlbum

                        expected =
                            Dict.fromList [ ( id, ( spotifyBlackFieldAlbum, [ AppleMusic, Spotify ] ) ) ]
                    in
                        Expect.equalDicts expected albums
            ]
        ]
