module Tests.AlbumTests exposing (all)

import Test exposing (..)
import Fuzz exposing (string)
import Expect
import Types exposing (..)
import Album
import Dict


spotifyBlackFieldAlbum : Album
spotifyBlackFieldAlbum =
    { hash = Album.hash "Blackfield" "Blackfield NYC - Blackfield Live In New York City"
    , artist = "Blackfield"
    , cover = "https://i.scdn.co/image/64ff3b770e913ffee89e46d1310e9fc9900054ed"
    , thumb = "https://i.scdn.co/image/e4d8e9ad4fa005f5fdda84f008880cb4fb85facd"
    , title = "Blackfield NYC - Blackfield Live In New York City"
    , providers = [ Spotify "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC" ]
    }


appleMusicBlackfieldAlbum : Album
appleMusicBlackfieldAlbum =
    { hash = Album.hash "Blackfield" "Blackfield NYC - Blackfield Live In New York City"
    , artist = "Blackfield"
    , cover = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/100x100bb.jpg"
    , thumb = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/60x60bb.jpg"
    , title = "Blackfield NYC - Blackfield Live In New York City"
    , providers = [ AppleMusic "https://itunes.apple.com/gb/album/blackfield/id416772823?uo=4" ]
    }


newAlbum : String -> Album
newAlbum rand =
    { hash = (Album.hash (rand ++ " artist") (rand ++ " title"))
    , artist = (rand ++ " artist")
    , cover = ("http://example.com/" ++ rand ++ "-cover.jpg")
    , thumb = ("http://example.com/" ++ rand ++ "-thumb.jpg")
    , title = (rand ++ " title")
    , providers = []
    }


all : Test
all =
    describe "Album"
        [ fuzz string "consistent hash" <|
            \a ->
                let
                    upper =
                        String.toUpper a
                in
                    Expect.equal (Album.hash a a) (Album.hash upper upper)
        , test "add a new album to empty collection" <|
            \() ->
                let
                    albums =
                        Album.add spotifyBlackFieldAlbum Album.empty

                    expected =
                        Dict.fromList [ ( spotifyBlackFieldAlbum.hash, spotifyBlackFieldAlbum ) ]
                in
                    Expect.equalDicts expected albums
        , test "add a duplicate album" <|
            \() ->
                let
                    initial =
                        Album.add spotifyBlackFieldAlbum Album.empty

                    albums =
                        Album.add appleMusicBlackfieldAlbum initial

                    expected =
                        Dict.fromList
                            [ ( spotifyBlackFieldAlbum.hash
                              , { spotifyBlackFieldAlbum
                                    | providers =
                                        [ Spotify "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC"
                                        , AppleMusic "https://itunes.apple.com/gb/album/blackfield/id416772823?uo=4"
                                        ]
                                }
                              )
                            ]
                in
                    Expect.equalDicts expected albums
        ]
