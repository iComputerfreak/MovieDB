//
//  Schema+Tag.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum Tag: String, SchemaEntity {
        static let _entityName = "Tag"
        
        // MARK: Attributes
        case id
        case name
        
        // MARK: Relationships
        case filterSettings
        case medias
    }
}
