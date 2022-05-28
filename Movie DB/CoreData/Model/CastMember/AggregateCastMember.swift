//
//  AggregateCastMember.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

/// Represents a `CastMember` that was decoded from the aggregate_casts key
struct AggregateCastMember: Decodable {
    var id: Int
    /// The name of the actor
    var name: String
    /// The names of the actor in the media
    var roles: [Role]
    /// The path to an image of the actor on TMDB
    var imagePath: String?
    
    func createCastMember(_ context: NSManagedObjectContext) -> CastMemberDummy {
        // List all role names, separated by comma
        let roleName = roles.map(\.characterName).joined(separator: ", ")
        return CastMemberDummy(id: id, name: name, roleName: roleName, imagePath: imagePath)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roles
        case imagePath = "profile_path"
    }
}

struct Role: Decodable {
    /// The name of the character/role in the media
    var characterName: String
    /// The number of episodes this character/role plays in
    var episodeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case characterName = "character"
        case episodeCount = "episode_count"
    }
}
