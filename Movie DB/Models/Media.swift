//
//  Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class Media {
    /// The data from TMDB
    var tmdbData: TMDBData?
    /// The data from JustWatch.com
    var justWatchData: JustWatchData?
    /// The type of media
    var type: MediaType = .movie
    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: Int = 0
    /// A list of user-specified tags
    var tags: [String] = []
    
    init(tmdbData: TMDBData?, justWatchData: JustWatchData?, type: MediaType, personalRating: Int = 0, tags: [String] = []) {
        self.tmdbData = tmdbData
        self.justWatchData = justWatchData
        self.type = type
        self.personalRating = personalRating
        self.tags = tags
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case show = "tv"
}
