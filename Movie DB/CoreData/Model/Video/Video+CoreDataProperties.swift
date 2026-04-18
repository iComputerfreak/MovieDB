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
        get { getInt(forKey: Schema.Video.resolution) }
        set { setInt(newValue, forKey: Schema.Video.resolution) }
    }

    /// The ISO-639-1 language code  (e.g. 'en')
    @NSManaged var language: String
    /// The ISO-3166-1 region code (e.g. 'US')
    @NSManaged var region: String
    /// The media this video belongs to
    @NSManaged var media: Media?
    
    /// Returns an URL that describes the video location
    /// Currently only supports YouTube videos
    var videoURL: URL? {
        if site.lowercased() == "youtube" {
            return URL(string: "https://youtube.com/watch?v=\(key)")
        } else {
            return nil
        }
    }

    /// Returns a thumbnail URL for the video if supported by the host
    var trailerThumbnailURL: URL? {
        trailerThumbnailURLs.first
    }

    /// Returns thumbnail URLs for the video if supported by the host
    var trailerThumbnailURLs: [URL] {
        guard site.lowercased() == "youtube" else { return [] }

        let hosts = ["i.ytimg.com", "img.youtube.com"]
        let imageNames = [
            "maxresdefault.jpg",
            "sddefault.jpg",
            "hqdefault.jpg",
            "mqdefault.jpg",
            "default.jpg",
            "0.jpg"
        ]

        return hosts.flatMap { host in
            imageNames.compactMap { imageName in
                URL(string: "https://\(host)/vi/\(key)/\(imageName)")
            }
        }
    }
     
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Video> {
        NSFetchRequest<Video>(entityName: Schema.Video._entityName)
    }
}

extension Video: Identifiable {}
