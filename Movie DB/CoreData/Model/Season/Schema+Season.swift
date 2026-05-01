// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum Season: String, SchemaEntityKey {
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
