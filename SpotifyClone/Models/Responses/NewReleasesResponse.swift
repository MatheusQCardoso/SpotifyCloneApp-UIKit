//
//  NewReleasesResponse.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 19/12/21.
//

import Foundation


struct NewReleasesResponse: Codable{
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable{
    let items: [Album]
}

//{
//    albums =     {
//        href = "https://api.spotify.com/v1/browse/new-releases?locale=en-US%2Cen%3Bq%3D0.9&offset=0&limit=1";
//        items =         (
//                        {
//                "album_type" = album;
//                artists =                 (
//                                        {
//                        "external_urls" =                         {
//                            spotify = "https://open.spotify.com/artist/757aE44tKEUQEqRuT6GnEB";
//                        };
//                        href = "https://api.spotify.com/v1/artists/757aE44tKEUQEqRuT6GnEB";
//                        id = 757aE44tKEUQEqRuT6GnEB;
//                        name = "Roddy Ricch";
//                        type = artist;
//                        uri = "spotify:artist:757aE44tKEUQEqRuT6GnEB";
//                    }
//                );
//                "available_markets" =                 (
//                    ZW
//                );
//                "external_urls" =                 {
//                    spotify = "https://open.spotify.com/album/1eVrpJbHRLBbioB9sb5b94";
//                };
//                href = "https://api.spotify.com/v1/albums/1eVrpJbHRLBbioB9sb5b94";
//                id = 1eVrpJbHRLBbioB9sb5b94;
//                images =                 (
//                                        {
//                        height = 640;
//                        url = "https://i.scdn.co/image/ab67616d0000b2738007e1fcf108e4270b6df942";
//                        width = 640;
//                    },
//                                        {
//                        height = 300;
//                        url = "https://i.scdn.co/image/ab67616d00001e028007e1fcf108e4270b6df942";
//                        width = 300;
//                    },
//                                        {
//                        height = 64;
//                        url = "https://i.scdn.co/image/ab67616d000048518007e1fcf108e4270b6df942";
//                        width = 64;
//                    }
//                );
//                name = "LIVE LIFE FAST";
//                "release_date" = "2021-12-17";
//                "release_date_precision" = day;
//                "total_tracks" = 18;
//                type = album;
//                uri = "spotify:album:1eVrpJbHRLBbioB9sb5b94";
//            }
//        );
//        limit = 1;
//        next = "https://api.spotify.com/v1/browse/new-releases?locale=en-US%2Cen%3Bq%3D0.9&offset=1&limit=1";
//        offset = 0;
//        previous = "<null>";
//        total = 100;
//    };
//}
