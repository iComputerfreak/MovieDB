//
//  Series.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class Show: Media {
    
    typealias EpisodeNumber = (season: Int, episode: Int)
    
    /// The season and episode number of the episode, the user has watched most recently
    @Published var lastEpisode: EpisodeNumber?
    
}
