// Copyright © 2023 Jonas Frey. All rights reserved.

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
