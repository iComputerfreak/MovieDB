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
    let id: Int
    /// The number of the season
    let seasonNumber: Int
    /// The number of episodes, this season has
    let episodeCount: Int
    /// The name of the season
    let name: String
    /// A short description of the season
    let overview: String?
    /// A path to the poster image of the season on TMDB
    let imagePath: String?
    /// The date when the season aired
    private let rawAirDate: String?
    /// The date, the season aired
    var airDate: Date? { rawAirDate == nil ? nil : JFUtils.tmdbDateFormatter.date(from: self.rawAirDate!) }
    
    init(id: Int, seasonNumber: Int, episodeCount: Int, name: String, overview: String?, imagePath: String?, rawAirDate: String?) {
        self.id = id
        self.seasonNumber = seasonNumber
        self.episodeCount = episodeCount
        self.name = name
        self.overview = overview
        self.imagePath = imagePath
        self.rawAirDate = rawAirDate
    }
    
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
