//
//  Video+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension Video {
    /// The video key
    @NSManaged var key: String
    /// The name of the video
    @NSManaged var name: String
    /// The site where the video was uploaded to
    @NSManaged var site: String
    /// The type of video (e.g. Trailer)
    @NSManaged var type: String
    /// The resolution of the video
    var resolution: Int {
        get { getInt(forKey: "resolution") }
        set { setInt(newValue, forKey: "resolution") }
    }

    /// The ISO-639-1 language code  (e.g. 'en')
    @NSManaged var language: String
    /// The ISO-3166-1 region code (e.g. 'US')
    @NSManaged var region: String
    /// The media this video belongs to
    @NSManaged var media: Media?
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Video> {
        NSFetchRequest<Video>(entityName: "Video")
    }
}

extension Video: Identifiable {}
