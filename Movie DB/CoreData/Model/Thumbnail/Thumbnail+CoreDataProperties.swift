//
//  Thumbnail+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Thumbnail {
    @NSManaged public var pngData: Data?
    @NSManaged public var media: Media?
    
    var image: UIImage? {
        if let data = self.pngData {
            return UIImage(data: data)
        }
        return nil
    }
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        NSFetchRequest<Thumbnail>(entityName: "Thumbnail")
    }
}

extension Thumbnail: Identifiable {}
