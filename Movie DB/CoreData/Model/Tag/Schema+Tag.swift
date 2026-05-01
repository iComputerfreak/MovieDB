// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum Tag: String, SchemaEntityKey {
        static let _entityName = "Tag"
        
        // MARK: Attributes
        case id
        case name
        
        // MARK: Relationships
        case filterSettings
        case medias
    }
}
