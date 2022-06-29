//
//  ProductionCompany+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

public extension ProductionCompany {
    /// The ID of the production company on TMDB
    var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }

    /// The name of the production company
    @NSManaged var name: String
    /// The path to the logo on TMDB
    @NSManaged var logoPath: String?
    /// The country of origin of the production company
    @NSManaged var originCountry: String
    /// The medias this company produced
    @NSManaged var medias: Set<Media>
    /// The shows that were released on this network
    @NSManaged var shows: Set<Show>
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<ProductionCompany> {
        NSFetchRequest<ProductionCompany>(entityName: "ProductionCompany")
    }
}

// MARK: Generated accessors for medias
public extension ProductionCompany {
    @objc(addMediasObject:)
    @NSManaged func addToMedias(_ value: Media)
    
    @objc(removeMediasObject:)
    @NSManaged func removeFromMedias(_ value: Media)
    
    @objc(addMedias:)
    @NSManaged func addToMedias(_ values: NSSet)
    
    @objc(removeMedias:)
    @NSManaged func removeFromMedias(_ values: NSSet)
}

// MARK: Generated accessors for shows
public extension ProductionCompany {
    @objc(addShowsObject:)
    @NSManaged func addToShows(_ value: Show)
    
    @objc(removeShowsObject:)
    @NSManaged func removeFromShows(_ value: Show)
    
    @objc(addShows:)
    @NSManaged func addToShows(_ values: NSSet)
    
    @objc(removeShows:)
    @NSManaged func removeFromShows(_ values: NSSet)
}

extension ProductionCompany: Identifiable {}
