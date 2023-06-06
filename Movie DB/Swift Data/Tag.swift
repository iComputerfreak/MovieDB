//
//  Tag.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.06.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftData

@Model
class SDTag {
    let id: UUID
    var name: String
    
    @Relationship(inverse: \SDMedia.tags)
    var medias: Set<SDMedia>
}

@Model
class SDMedia {
    let id: UUID
    
    @Relationship
    var tags: Set<SDTag>
}
