//
//  Schema+CDColor.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

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
