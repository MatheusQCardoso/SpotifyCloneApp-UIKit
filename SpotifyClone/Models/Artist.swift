//
//  Artist.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 18/12/21.
//

import Foundation

struct Artist: Codable{
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
