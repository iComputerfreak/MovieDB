// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum DynamicMediaList: String, SchemaEntityKey {
        static let _entityName = "DynamicMediaList"
        
        // MARK: Attributes
        case iconName
        case id
        case name
        case subtitleContent
        case sortingDirection
        case sortingOrder
        case iconRenderingMode
        
        // MARK: Relationships
        case filterSetting
        case iconColor
    }
}
