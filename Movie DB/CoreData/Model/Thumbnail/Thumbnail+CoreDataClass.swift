//
//  Thumbnail+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Thumbnail)
public class Thumbnail: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, pngData: Data?) {
        self.init(context: context)
        self.pngData = pngData
    }

}
