// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum CDColor: String, SchemaEntityKey {
        static let _entityName = "CDColor"
        
        // MARK: Attributes
        case redComponent
        case greenComponent
        case blueComponent
        case alphaComponent
        
        // MARK: Relationships
        case userMediaLists
        case dynamicMediaLists
        case parentalRatings
    }
}
