// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum WatchProvider: String, SchemaEntityKey {
        static let _entityName = "WatchProvider"
        
        // MARK: Attributes
        case id
        case name
        case type
        case imagePath
        case priority
        
        // MARK: Relationships
        case medias
    }
}
