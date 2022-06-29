//
//  Thumbnail+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

public extension Thumbnail {
    @NSManaged var pngData: Data?
    @NSManaged var media: Media?
    
    internal var image: UIImage? {
        if let data = pngData {
            return UIImage(data: data)
        }
        return nil
    }
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        NSFetchRequest<Thumbnail>(entityName: "Thumbnail")
    }
}

extension Thumbnail: Identifiable {}
