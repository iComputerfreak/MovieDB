//
//  MediaType.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case show = "tv"
}
