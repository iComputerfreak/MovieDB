// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum Video: String, SchemaEntityKey {
        static let _entityName = "Video"
        
        // MARK: Attributes
        case key
        case language
        case name
        case region
        case resolution
        case site
        case type
        
        // MARK: Relationships
        case media
    }
}
