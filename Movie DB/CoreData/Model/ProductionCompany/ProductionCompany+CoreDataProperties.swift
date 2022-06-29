//
//  ProductionCompany+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

extension ProductionCompany {
    /// The ID of the production company on TMDB
    public var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }
    /// The name of the production company
    @NSManaged public var name: String
    /// The path to the logo on TMDB
    @NSManaged public var logoPath: String?
    /// The country of origin of the production company
    @NSManaged public var originCountry: String
    /// The medias this company produced
    @NSManaged public var medias: Set<Media>
    /// The shows that were released on this network
    @NSManaged public var shows: Set<Show>
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<ProductionCompany> {
        NSFetchRequest<ProductionCompany>(entityName: "ProductionCompany")
    }
}

// MARK: Generated accessors for medias
extension ProductionCompany {
    @objc(addMediasObject:)
    @NSManaged public func addToMedias(_ value: Media)
    
    @objc(removeMediasObject:)
    @NSManaged public func removeFromMedias(_ value: Media)
    
    @objc(addMedias:)
    @NSManaged public func addToMedias(_ values: NSSet)
    
    @objc(removeMedias:)
    @NSManaged public func removeFromMedias(_ values: NSSet)
}

// MARK: Generated accessors for shows
extension ProductionCompany {
    @objc(addShowsObject:)
    @NSManaged public func addToShows(_ value: Show)
    
    @objc(removeShowsObject:)
    @NSManaged public func removeFromShows(_ value: Show)
    
    @objc(addShows:)
    @NSManaged public func addToShows(_ values: NSSet)
    
    @objc(removeShows:)
    @NSManaged public func removeFromShows(_ values: NSSet)
}

extension ProductionCompany: Identifiable {}
