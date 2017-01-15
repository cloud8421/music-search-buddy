module Tests.SpotifyTests exposing (all)

import Test exposing (..)
import Expect
import Spotify
import Json.Decode
import Types exposing (..)


jsonResponse : String
jsonResponse =
    """
    {
      "albums" : {
        "href" : "https://api.spotify.com/v1/search?query=album%3Ablackfield&offset=0&limit=20&type=album",
        "items" : [ {
          "album_type" : "album",
          "artists" : [ {
            "external_urls" : {
              "spotify" : "https://open.spotify.com/artist/3xrzXKnScjOEoy172vsJMW"
            },
            "href" : "https://api.spotify.com/v1/artists/3xrzXKnScjOEoy172vsJMW",
            "id" : "3xrzXKnScjOEoy172vsJMW",
            "name" : "Blackfield",
            "type" : "artist",
            "uri" : "spotify:artist:3xrzXKnScjOEoy172vsJMW"
          } ],
          "available_markets" : [ "CA", "US" ],
          "external_urls" : {
            "spotify" : "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC"
          },
          "href" : "https://api.spotify.com/v1/albums/0eOqcRD7o9mQI2hFSKkPgC",
          "id" : "0eOqcRD7o9mQI2hFSKkPgC",
          "images" : [ {
            "height" : 580,
            "url" : "https://i.scdn.co/image/64ff3b770e913ffee89e46d1310e9fc9900054ed",
            "width" : 640
          }, {
            "height" : 272,
            "url" : "https://i.scdn.co/image/c3fb71e1e64fd089387292820e93efe3801e8bef",
            "width" : 300
          }, {
            "height" : 58,
            "url" : "https://i.scdn.co/image/e4d8e9ad4fa005f5fdda84f008880cb4fb85facd",
            "width" : 64
          } ],
          "name" : "Blackfield",
          "type" : "album",
          "uri" : "spotify:album:0eOqcRD7o9mQI2hFSKkPgC"
        } ],
        "limit" : 20,
        "next" : null,
        "offset" : 0,
        "previous" : null,
        "total" : 3
      }
    }
    """


all : Test
all =
    describe "Spotify"
        [ test "JSON decode" <|
            \() ->
                let
                    album =
                        { id = 2839173192
                        , title = "Blackfield"
                        , artist = "Blackfield"
                        , thumb = "https://i.scdn.co/image/e4d8e9ad4fa005f5fdda84f008880cb4fb85facd"
                        , cover = "https://i.scdn.co/image/c3fb71e1e64fd089387292820e93efe3801e8bef"
                        , providers = [ Spotify "https://open.spotify.com/album/0eOqcRD7o9mQI2hFSKkPgC" ]
                        }

                    decode =
                        Json.Decode.decodeString Spotify.albumSearchDecoder
                in
                    Expect.equal (Ok [ album ]) (decode jsonResponse)
        ]
