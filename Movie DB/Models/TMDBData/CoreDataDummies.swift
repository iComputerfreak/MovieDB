//
//  CoreDataDummies.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

// swiftlint:disable type_contents_order

protocol CoreDataDummy: Hashable {
    associatedtype Entity: NSManagedObject
    
    /// Creates a new NSManagedObject in the given context with the properties of this dummy object
    /// - Parameter context: The context to create the object in
    /// - Returns: The created object
    func transferInto(context: NSManagedObjectContext) -> Entity
}

struct GenreDummy: CoreDataDummy, Decodable {
    let id: Int
    let name: String
    
    func transferInto(context: NSManagedObjectContext) -> Genre {
        let genre = Genre(context: context)
        genre.id = id
        genre.name = name
        return genre
    }
}

struct ProductionCompanyDummy: CoreDataDummy, Decodable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
    
    func transferInto(context: NSManagedObjectContext) -> ProductionCompany {
        let pc = ProductionCompany(context: context)
        pc.id = id
        pc.name = name
        pc.logoPath = logoPath
        pc.originCountry = originCountry
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

struct VideoDummy: CoreDataDummy, Decodable {
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
        video.key = key
        video.name = name
        video.site = site
        video.type = type
        video.resolution = resolution
        video.language = language
        video.region = region
        return video
    }
}

struct SeasonDummy: CoreDataDummy, Decodable {
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
        season.id = id
        season.seasonNumber = seasonNumber
        season.episodeCount = episodeCount
        season.name = name
        season.overview = overview
        season.imagePath = imagePath
        season.airDate = airDate
        return season
    }
}

struct WatchProviderDummy: CoreDataDummy {
    typealias Entity = WatchProvider
    
    let id: Int
    let priority: Int
    let imagePath: String?
    let name: String
    let type: WatchProvider.ProviderType
    
    init(id: Int, priority: Int, imagePath: String? = nil, name: String, type: WatchProvider.ProviderType) {
        self.id = id
        self.priority = priority
        self.imagePath = imagePath
        self.name = name
        self.type = type
    }
    
    init(info: WatchProviderInfoDummy, type: WatchProvider.ProviderType) {
        self.id = info.id
        self.priority = info.priority
        self.imagePath = info.imagePath
        self.name = info.name
        self.type = type
    }
    
    func transferInto(context: NSManagedObjectContext) -> WatchProvider {
        WatchProvider(
            context: context,
            id: id,
            type: type,
            name: name,
            imagePath: imagePath,
            priority: priority
        )
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
        let allMatching = (try? fetch(fetchRequest)) ?? []
        
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
            NSPredicate(format: "%K = %d", Schema.Genre.id.rawValue, dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
    
    func importDummies(_ dummies: [ProductionCompanyDummy]) -> [ProductionCompany] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", Schema.ProductionCompany.id.rawValue, dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
        
    func importDummies(_ dummies: [VideoDummy]) -> [Video] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", Schema.Video.key.rawValue, dummy.key)
        } isEqual: { dummy, entity in
            dummy.key == entity.key
        }
    }
    
    func importDummies(_ dummies: [SeasonDummy]) -> [Season] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", Schema.Season.id.rawValue, dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
    
    func importDummies(_ dummies: [WatchProviderDummy]) -> [WatchProvider] {
        importDummies(dummies) { dummy in
            NSPredicate(format: "%K = %d", Schema.WatchProvider.id.rawValue, dummy.id)
        } isEqual: { dummy, entity in
            dummy.id == entity.id
        }
    }
}
