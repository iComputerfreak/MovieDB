//
//  Schema+Movie.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum Movie: String, SchemaEntityKey {
        static let _entityName = "Movie"
        
        // MARK: Attributes
        case budget
        case isAdult
        case releaseDate
        case revenue
        case runtime
        case watchedState
        
        // MARK: Relationships
    }
}
