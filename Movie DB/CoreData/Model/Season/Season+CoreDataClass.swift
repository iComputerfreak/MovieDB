//
//  Season+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

/// Represents a season of a show
@objc(Season)
public class Season: NSManagedObject, Decodable {
    // MARK: - Decodable Conformance
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.seasonNumber = try container.decode(Int.self, forKey: .seasonNumber)
        self.episodeCount = try container.decode(Int.self, forKey: .episodeCount)
        self.name = try container.decode(String.self, forKey: .name)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        let rawAirDate = try container.decode(String?.self, forKey: .airDate)
        self.airDate = Utils.tmdbDateFormatter.date(from: rawAirDate ?? "")
        // self.show will be set by CoreData when adding the season to the show
        self.show = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case name
        case overview
        case imagePath = "poster_path"
        case airDate = "air_date"
    }
}
