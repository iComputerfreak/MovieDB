//
//  CDColor+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

public extension CDColor {
    @NSManaged var redComponent: Double
    @NSManaged var greenComponent: Double
    @NSManaged var blueComponent: Double
    @NSManaged var alphaComponent: Double
    
    @NSManaged var dynamicMediaLists: DynamicMediaList?
    @NSManaged var userMediaLists: UserMediaList?
    @NSManaged var parentalRatings: ParentalRating?
    
    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CDColor> {
        NSFetchRequest<CDColor>(entityName: Schema.CDColor._entityName)
    }
}

extension CDColor: Identifiable {}
