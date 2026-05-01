// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum FilterSetting: String, SchemaEntityKey {
        static let _entityName = "FilterSetting"
        
        // MARK: Attributes
        case id
        case isAdult
        case maxNumberOfSeasons
        case maxRating
        case maxYear
        case mediaType
        case minNumberOfSeasons
        case minRating
        case minYear
        case showTypes
        case statuses
        case watchAgain
        case watchState
        
        // MARK: Relationships
        case genres
        case mediaList
        case tags
    }
}
