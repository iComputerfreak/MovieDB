//
//  Schema+FilterSetting.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum FilterSetting: String, SchemaEntity {
        static let _entityName = "FilterSetting"
        
        // MARK: Attributes
        case id
        case isAdult
        case maxNumberOfSeasons
        case maxRating
        case maxYear
        case mediaType
        case minNumberOfSeasons
        case minRating
        case minYear
        case showTypes
        case statuses
        case watchAgain
        case watched
        
        // MARK: Relationships
        case genres
        case mediaList
        case tags
    }
}
