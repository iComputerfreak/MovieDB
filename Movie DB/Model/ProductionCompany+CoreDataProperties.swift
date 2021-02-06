//
//  ProductionCompany+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

extension ProductionCompany {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductionCompany> {
        return NSFetchRequest<ProductionCompany>(entityName: "ProductionCompany")
    }
    
    /// The ID of the production company on TMDB
    @NSManaged public var id: Int64
    /// The name of the production company
    @NSManaged public var name: String
    /// The path to the logo on TMDB
    @NSManaged public var logoPath: String?
    /// The country of origin of the production company
    @NSManaged public var originCountry: String
    
}

extension ProductionCompany: Identifiable {
    
}
