//
//  Video+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

/// Represents a video on some external site
@objc(Video)
public class Video: NSManagedObject {
    override public var description: String {
        "Video(key: \(key), name: \(name), type: \(type))"
    }
}
