//
//  Settings.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 18/12/21.
//

import Foundation

struct Section{
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
