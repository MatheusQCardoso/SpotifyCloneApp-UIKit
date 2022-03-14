//
//  AuthResponse.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 18/12/21.
//

import Foundation

struct AuthResponse : Codable{
    let access_token : String
    let expires_in : Int
    let refresh_token : String?
    let scope : String
    let token_type : String
}

