//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 18/12/21.
//

import Foundation

struct UserProfile: Codable{
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    // let followers: [String: Codable?]
    let href: String
    let id: String
    let images: [ImageData]
    let product: String
    let type: String
    let uri: String
}
