//
//  MediaLibrary.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CoreData


class MediaLibrary2 {
    
    /// The shared `MediaLibrary` instance.
    static let shared: MediaLibrary = MediaLibrary.load() // TODO: Fetch library
    
    
    
    
    
    /// Appends the given media object to the library
    /// - Parameter object: The object to append
    func append(_ object: Media) {
        self.mediaList.append(object)
        save()
    }
    
    /// Appends the contents of the given array to the library
    /// - Parameter objects: The objects to append
    func append(contentsOf objects: [Media]) {
        self.mediaList.append(contentsOf: objects)
        save()
    }
    
    /// Removes the media object with the given ID
    /// - Parameter id: The ID of the media object to remove
    func remove(id: Int) {
        let index = self.mediaList.firstIndex(where: { $0.id == id })
        guard index != nil else {
            return
        }
        let id = mediaList[index!].id
        self.mediaList.remove(at: index!)
        let thumbnailPath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(id).png")
        // Try to delete the thumbnail from disk
        self.save()
        DispatchQueue.global().async {
            // It's not super bad, if we can't remove the thumbnail from disk...
            // We can ignore any errors thrown
            try? FileManager.default.removeItem(at: thumbnailPath)
        }
    }
    
    
    
    // MARK: - Problems
    /// Returns all problems in this library
    /// - Returns: All problematic media objects and their missing information
    func problems() -> [Media: Set<Media.MediaInformation>] {
        var problems: [Media: Set<Media.MediaInformation>] = [:]
        for media in mediaList {
            if !media.missingInformation.isEmpty {
                problems[media] = media.missingInformation
            }
        }
        return problems
    }
    
    /// Returns the list of duplicate TMDB IDs
    /// - Returns: The list of duplicate TMDB IDs
    func duplicates() -> [Int?: [Media]] {
        // Group the media objects by their TMDB IDs
        return Dictionary(grouping: self.mediaList, by: \.tmdbID)
            // Filter out all IDs with only one media object
            .filter { (key: Int?, value: [Media]) in
                return value.count > 1
            }
    }
    
}
