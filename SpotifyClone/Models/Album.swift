//
//  Album.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 19/12/21.
//

import Foundation

struct Album: Codable{
    let album_type: String
    let available_markets: [String]
    let id: String
    let images: [ImageData]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
