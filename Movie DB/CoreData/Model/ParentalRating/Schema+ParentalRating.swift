// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum ParentalRating: String, SchemaEntityKey {
        static let _entityName = "ParentalRating"
        
        // MARK: Attributes
        case id
        case countryCode
        case label
        case colorSpace
        case redComponent
        case greenComponent
        case blueComponent
        case alphaComponent
        
        // MARK: Relationships
        case medias
        case color
    }
}
