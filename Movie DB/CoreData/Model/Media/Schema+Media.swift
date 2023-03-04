//
//  Schema+Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

protocol SchemaEntity {
    static var _entityName: String { get }
}

extension Schema {
    enum Media: String, SchemaEntity {
        static let _entityName = "Media"
        
        // MARK: Attributes
        case id
        case type
        case personalRating
        case watchAgain
        case notes
        case tmdbID
        case title
        case originalTitle
        case imagePath
        case genres
        case overview
        case tagline
        case status
        case originalLanguage
        case productionCompanies
        case homepageURL
        case productionCountries
        case popularity
        case voteAverage
        case voteCount
        case keywords
        case translations
        case videos
        case tags
        case creationDate
        case modificationDate
        case releaseDateOrFirstAired
        case parentalRatingColor
        case parentalRatingLabel
        case watchProviders
        case isFavorite
        case isOnWatchlist
        
        // MARK: Relationships
        case userLists
    }
}
