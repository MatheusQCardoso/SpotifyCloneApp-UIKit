//
//  FeaturedPlaylistsResponse.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 19/12/21.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable{
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable{
    let items: [Playlist]
}
