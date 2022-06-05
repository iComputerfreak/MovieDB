//
//  CoreDataDummies.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

// swiftlint:disable type_contents_order file_types_order

protocol CoreDataDummy: Decodable, Hashable {
    associatedtype Entity: NSManagedObject
    
    /// Creates a new NSManagedObject in the given context with the properties of this dummy object
    /// - Parameter context: The context to create the object in
    /// - Returns: The created object
    func transferInto(context: NSManagedObjectContext) -> Entity
}

struct GenreDummy: CoreDataDummy {
    let id: Int
    let name: String
    
    func transferInto(context: NSManagedObjectContext) -> Genre {
        let genre = Genre(context: context)
        genre.id = self.id
        genre.name = self.name
        return genre
    }
}

struct ProductionCompanyDummy: CoreDataDummy {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
    
    func transferInto(context: NSManagedObjectContext) -> ProductionCompany {
        let pc = ProductionCompany(context: context)
        pc.id = self.id
        pc.name = self.name
        pc.logoPath = self.logoPath
        pc.originCountry = self.originCountry
        return pc
    }
}

struct CastMemberDummy: Decodable, Identifiable {
    let id: Int
    let name: String
    let roleName: String
    let imagePath: String?
    
    init(id: Int, name: String, roleName: String, imagePath: String?) {
        self.id = id
        self.name = name
        self.roleName = roleName
        self.imagePath = imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roleName = "character"
        case imagePath = "profile_path"
    }
    
    enum CreditsCodingKeys: String, CodingKey {
        case cast
    }
}

struct VideoDummy: CoreDataDummy {
    let key: String
    let name: String
    let site: String
    let type: String
    let resolution: Int
    let language: String
    let region: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
        case type
        case resolution = "size"
        case language = "iso_639_1"
        case region = "iso_3166_1"
    }
    
    func transferInto(context: NSManagedObjectContext) -> Video {
        let video = Video(context: context)
        video.key = self.key
        video.name = self.name
        video.site = self.site
        video.type = self.type
        video.resolution = self.resolution
        video.language = self.language
        video.region = self.region
        return video
    }
}

struct SeasonDummy: CoreDataDummy {
    let id: Int
    let seasonNumber: Int
    let episodeCount: Int
    let name: String
    let overview: String?
    let imagePath: String?
    let airDate: Date?
    
    init(
        id: Int,
        seasonNumber: Int,
        episodeCount: Int,
        name: String,
        overview: String?,
        imagePath: String?,
        airDate: Date?
    ) {
        self.id = id
        self.seasonNumber = seasonNumber
        self.episodeCount = episodeCount
        self.name = name
        self.overview = overview
        self.imagePath = imagePath
        self.airDate = airDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.seasonNumber = try container.decode(Int.self, forKey: .seasonNumber)
        self.episodeCount = try container.decode(Int.self, forKey: .episodeCount)
        self.name = try container.decode(String.self, forKey: .name)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        let rawAirDate = try container.decode(String?.self, forKey: .airDate)
        self.airDate = Utils.tmdbDateFormatter.date(from: rawAirDate ?? "")
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
    
    func transferInto(context: NSManagedObjectContext) -> Season {
        let season = Season(context: context)
        season.id = self.id
        season.seasonNumber = self.seasonNumber
        season.episodeCount = self.episodeCount
        season.name = self.name
        season.overview = self.overview
        season.imagePath = self.imagePath
        season.airDate = self.airDate
        return season
    }
}

extension NSManagedObjectContext {
    func importDummies<Entity, Dummy>(
        _ dummies: [Dummy],
        predicate: (Dummy) -> NSPredicate,
        isEqual: (Dummy, Entity) -> Bool
    ) -> [Entity] where Dummy: CoreDataDummy, Dummy.Entity == Entity {
        assert(dummies.count < 1000, "The NSFetchRequest below will fail for predicates with more than 1000 elements")
        // Fetch all matching objects at once
        let fetchRequest: NSFetchRequest<Entity> = NSFetchRequest(entityName: Entity.entity().name!)
        let predicates = dummies.map(predicate)
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let allMatching = (try? self.fetch(fetchRequest)) ?? []
        
        var result: [Entity] = []
        for dummy in dummies {
            // Check if the object already exists
            if let match = allMatching.first(where: { isEqual(dummy, $0) }) {
                result.append(match)
            } else {
                // Create new CoreData object
                result.append(dummy.transferInto(context: self))
            }
        }
        
        return result
    }
    
    func importDummies(_ dummies: [GenreDummy]) -> [Genre] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", "id", dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
    
    func importDummies(_ dummies: [ProductionCompanyDummy]) -> [ProductionCompany] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", "id", dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
        
    func importDummies(_ dummies: [VideoDummy]) -> [Video] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", "key", dummy.key)
        } isEqual: { dummy, entity in
            dummy.key == entity.key
        }
    }
    
    func importDummies(_ dummies: [SeasonDummy]) -> [Season] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", "id", dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
}