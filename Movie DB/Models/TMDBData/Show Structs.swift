//
//  Season.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents a season of a show
struct Season: Codable, Hashable, Identifiable {
    /// The id of the season on TMDB
    var id: Int
    /// The number of the season
    var seasonNumber: Int
    /// The number of episodes, this season has
    var episodeCount: Int
    /// The name of the season
    var name: String
    /// A short description of the season
    var overview: String?
    /// A path to the poster image of the season on TMDB
    var imagePath: String?
    /// The date when the season aired
    var rawAirDate: String?
    /// The date, the season aired
    var airDate: Date? { rawAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawAirDate!) }
    
    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case name
        case overview
        case imagePath = "poster_path"
        case rawAirDate = "air_date"
    }
}

enum ShowType: String, Codable, CaseIterable {
    case documentary = "Documentary"
    case news = "News"
    case miniseries = "Miniseries"
    case reality = "Reality"
    case scripted = "Scripted"
    case talkShow = "Talk Show"
    case video = "Video"
}
