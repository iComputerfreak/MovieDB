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
class SDTag: Codable {
    @Attribute(.unique)
    let id = UUID()
    var name: String
    
    @Relationship(inverse: \SDMedia.tags)
    var medias: Set<SDMedia> = []
    
    var description: String {
        "\(String(describing: Self.self))(id: \(id.uuidString), name: \(name), medias: \(medias.count) objects)"
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

@Model
class SDMedia {
//    let id: UUID
    
    // TODO: Compiler is confused which getValue function it is supposed to take. getValue(Decodable) or getValue(PersistentModel)
    @Relationship
    var tags: Set<SDTag> = []
}
