// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum ProductionCompany: String, SchemaEntityKey {
        static let _entityName = "ProductionCompany"
        
        // MARK: Attributes
        case id
        case logoPath
        case name
        case originCountry
        
        // MARK: Relationships
        case medias
        case shows
    }
}
