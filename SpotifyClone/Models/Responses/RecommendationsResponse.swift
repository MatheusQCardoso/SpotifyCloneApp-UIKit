//
//  RecommendationsResponse.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 19/12/21.
//

import Foundation

struct RecommendationsResponse: Codable{
    let tracks: [AudioTrack]
}
