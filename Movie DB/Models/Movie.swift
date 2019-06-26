//
//  Movie.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class Movie: Media<TMDBMovieData> {
    
    /// Whether the user has watched the media (partly or fully)
    var watched: Bool = false
    
}
