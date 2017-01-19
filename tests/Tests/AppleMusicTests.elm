module Tests.AppleMusicTests exposing (all)

import Test exposing (..)
import Expect
import AppleMusic
import Json.Decode
import Types exposing (..)


jsonResponse : String
jsonResponse =
    """
    {
        "resultCount": 30,
        "results": [
            {
                "wrapperType": "collection",
                "collectionType": "Album",
                "artistId": 45319653,
                "collectionId": 416772823,
                "amgArtistId": 671068,
                "artistName": "Blackfield",
                "collectionName": "Blackfield",
                "collectionCensoredName": "Blackfield",
                "artistViewUrl": "https://itunes.apple.com/gb/artist/blackfield/id45319653?uo=4",
                "collectionViewUrl": "https://itunes.apple.com/gb/album/blackfield/id416772823?uo=4",
                "artworkUrl60": "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/60x60bb.jpg",
                "artworkUrl100": "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/100x100bb.jpg",
                "collectionPrice": 5.99,
                "collectionExplicitness": "notExplicit",
                "trackCount": 10,
                "copyright": "℗ 2004 Snapper Music",
                "country": "GBR",
                "currency": "GBP",
                "releaseDate": "2011-01-17T08:00:00Z",
                "primaryGenreName": "Rock"
            }
        ]
    }
    """


all : Test
all =
    describe "Spotify"
        [ test "JSON decode" <|
            \() ->
                let
                    album =
                        { hash = 2839173192
                        , title = "Blackfield"
                        , artist = "Blackfield"
                        , thumb = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/58x58bb.jpg"
                        , cover = "http://is1.mzstatic.com/image/thumb/Music/v4/cd/b9/c6/cdb9c6b3-956e-e527-f28f-97e86d563845/source/178x178bb.jpg"
                        , price = Just 5.99
                        , providers = [ ( AppleMusic, "416772823" ) ]
                        }

                    decode =
                        Json.Decode.decodeString AppleMusic.albumSearchDecoder
                in
                    Expect.equal (Ok [ album ]) (decode jsonResponse)
        ]
