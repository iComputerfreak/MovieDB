// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum UserMediaList: String, SchemaEntityKey {
        static let _entityName = "UserMediaList"
        
        // MARK: Attributes
        case iconName
        case id
        case name
        case subtitleContent
        case sortingDirection
        case sortingOrder
        case iconRenderingMode
        
        // MARK: Relationships
        case medias
        case iconColor
    }
}
