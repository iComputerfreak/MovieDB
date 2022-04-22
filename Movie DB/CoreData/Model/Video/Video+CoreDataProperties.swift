//
//  Video+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

extension Video {
    
    /// The video key
    @NSManaged public var key: String
    /// The name of the video
    @NSManaged public var name: String
    /// The site where the video was uploaded to
    @NSManaged public var site: String
    /// The type of video (e.g. Trailer)
    @NSManaged public var type: String
    /// The resolution of the video
    public var resolution: Int {
        get { getInt(forKey: "resolution") }
        set { setInt(newValue, forKey: "resolution") }
    }
    /// The ISO-639-1 language code  (e.g. 'en')
    @NSManaged public var language: String
    /// The ISO-3166-1 region code (e.g. 'US')
    @NSManaged public var region: String
    /// The media this video belongs to
    @NSManaged public var media: Media?
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }
}

extension Video: Identifiable {}
