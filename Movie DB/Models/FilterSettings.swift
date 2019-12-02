//
//  FilterSettings.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct FilterSettings: Codable {
    
    // MARK: Smart Filters
    
    // MARK: Basic Filters
    var type: MediaType? = nil
    var genres: [Genre] = []
    // var parentalRating
    var rating: ClosedRange<Int>? = nil
    var year: ClosedRange<Int>? = nil
    // Movie Speicifc
    var runtime: ClosedRange<Int>? = nil
    // Show Specific
    var showType: ShowType? = nil
    var showStatus: MediaStatus? = nil
    var numberOfSeasons: ClosedRange<Int>? = nil
    
    // MARK: Extended Info
    var tmdbPopularity: ClosedRange<Float>? = nil
    var tmdbScoring: ClosedRange<Float>? = nil
    
    // MARK: User Data
    var watched: Bool? = nil
    var watchAgain: Bool? = nil
    var tags: [Int] = []
    
}
