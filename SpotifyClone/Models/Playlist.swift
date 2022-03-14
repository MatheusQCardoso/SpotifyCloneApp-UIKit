//
//  Playlist.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 18/12/21.
//

import Foundation

struct Playlist: Codable{
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [ImageData]
    let name: String
    let owner: User
}

struct User: Codable{
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
