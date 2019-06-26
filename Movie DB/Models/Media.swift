//
//  Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class Media<TMDBType: TMDBData> {
    /// The data from TMDB
    var tmdbData: TMDBType?
    /// The data from JustWatch.com
    var justWatchData: JustWatchData?
    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: Int = 0
    /// A list of user-specified tags
    var tags: [String] = []
}
