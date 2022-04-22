//
//  CastMember+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

/// Represents an actor starring in a specific movie
@objc(CastMember)
public class CastMember: NSManagedObject, Decodable {
    
    // MARK: - Initializers
    
    public convenience init(
        context: NSManagedObjectContext,
        id: Int,
        name: String,
        roleName: String,
        imagePath: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.roleName = roleName
        self.imagePath = imagePath
    }
    
    // MARK: - Decodable Conformance
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.roleName = try container.decode(String.self, forKey: .roleName)
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roleName = "character"
        case imagePath = "profile_path"
    }
}
