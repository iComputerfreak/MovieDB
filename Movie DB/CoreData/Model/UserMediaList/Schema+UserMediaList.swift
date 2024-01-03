//
//  Schema+UserMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum UserMediaList: String, SchemaEntityKey {
        static let _entityName = "UserMediaList"
        
        // MARK: Attributes
        case iconName
        case id
        case name
        case sortingDirection
        case sortingOrder
        case iconRenderingMode
        
        // MARK: Relationships
        case medias
        case iconColor
    }
}
