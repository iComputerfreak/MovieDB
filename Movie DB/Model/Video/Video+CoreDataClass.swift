//
//  Video+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

/// Represents a video on some external site
@objc(Video)
public class Video: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.name = try container.decode(String.self, forKey: .name)
        self.site = try container.decode(String.self, forKey: .site)
        self.type = try container.decode(String.self, forKey: .type)
        self.resolution = try container.decode(Int.self, forKey: .resolution)
        self.language = try container.decode(String.self, forKey: .language)
        self.region = try container.decode(String.self, forKey: .region)
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
        case type
        case resolution = "size"
        case language = "iso_639_1"
        case region = "iso_3166_1"
    }
}
