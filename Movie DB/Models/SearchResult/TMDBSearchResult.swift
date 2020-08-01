//
//  TMDBSearchResult.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class TMDBSearchResult: Codable, Identifiable {
    // Basic Data
    /// The TMDB ID of the media
    var id: Int
    /// The name of the media
    var title: String
    /// The type of media
    var mediaType: MediaType
    /// The path of the media poster image on TMDB
    var imagePath: String?
    /// A short media description
    var overview: String?
    /// The original tile of the media
    var originalTitle: String
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    var originalLanguage: String
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    var popularity: Float
    /// The average rating on TMDB
    var voteAverage: Float
    /// The number of votes that were cast on TMDB
    var voteCount: Int
    /// Whether the result is a movie and is for adults only
    var isAdultMovie: Bool? { (self as? TMDBMovieSearchResult)?.isAdult }
    
    init(id: Int, title: String, mediaType: MediaType, imagePath: String? = nil, overview: String? = nil, originalTitle: String, originalLanguage: String, popularity: Float, voteAverage: Float, voteCount: Int) {
        self.id = id
        self.title = title
        self.mediaType = mediaType
        self.imagePath = imagePath
        self.overview = overview
        self.originalTitle = originalTitle
        self.originalLanguage = originalLanguage
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case mediaType = "media_type"
        case imagePath = "poster_path"
        case overview
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
