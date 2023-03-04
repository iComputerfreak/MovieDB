//
//  Schema+DynamicMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Schema {
    enum DynamicMediaList: String, SchemaEntity {
        static let _entityName = "DynamicMediaList"
        
        // MARK: Attributes
        case iconName
        case id
        case name
        case sortingDirection
        case sortingOrder
        
        // MARK: Relationships
        case filterSetting
    }
}
