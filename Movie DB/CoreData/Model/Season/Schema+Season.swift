//
//  Schema+Season.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum Season: String, SchemaEntity {
        static let _entityName = "Season"
        
        // MARK: Attributes
        case airDate
        case episodeCount
        case id
        case imagePath
        case name
        case overview
        case seasonNumber
        
        // MARK: Relationships
        case show
    }
}
