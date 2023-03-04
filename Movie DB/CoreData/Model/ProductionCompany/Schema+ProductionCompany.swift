//
//  Schema+ProductionCompany.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum ProductionCompany: String, SchemaEntity {
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
