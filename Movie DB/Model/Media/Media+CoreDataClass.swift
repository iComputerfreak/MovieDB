//
//  Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import JFSwiftUI
import CloudKit
import CoreData

/// Represents a media object in the library
@objc(Media)
public class Media: NSManagedObject {
    
    // MARK: - Missing Information
    
    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
        self.personalRating = .noRating
        self.tags = []
        
        // The castMembersSortOrder array contains the sorted CastMember IDs
        self.castMembersSortOrder = tmdbData.cast.map(\.id)
        
        self.id = MediaLibrary.shared.nextID
        self.type = type
        
        // Set all properties from the tmdbData object
        self.tmdbID = tmdbData.id
        self.title = tmdbData.title
        self.originalTitle = tmdbData.originalTitle
        self.imagePath = tmdbData.imagePath
        self.genres = Set(transferIntoContext(tmdbData.genres))
        self.overview = tmdbData.overview
        self.status = tmdbData.status
        self.originalLanguage = tmdbData.originalLanguage
        self.productionCompanies = Set(transferIntoContext(tmdbData.productionCompanies))
        self.homepageURL = tmdbData.homepageURL
        self.popularity = tmdbData.popularity
        self.voteAverage = tmdbData.voteAverage
        self.voteCount = tmdbData.voteCount
        self.cast = Set(transferIntoContext(tmdbData.cast))
        self.keywords = tmdbData.keywords
        self.translations = tmdbData.translations
        self.videos = Set(transferIntoContext(tmdbData.videos))
    }
    
    func transferIntoContext<T: NSManagedObject>(_ objects: [T]) -> [T] {
        // Make sure to use the objects from the correct context
        return objects.map({ managedObjectContext!.object(with: $0.objectID) as! T })
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.castMembersSortOrder = []
        self.tags = []
    }
    
    // MARK: - Functions
    
    /// Triggers a reload of the thumbnail using the `imagePath` in `tmdbData`
    func loadThumbnailAsync(force: Bool = false) {
        guard thumbnail == nil || force else {
            // Thumbnail already present, don't download again, overridden with force parameter
            return
        }
        guard let imagePath = imagePath, !imagePath.isEmpty else {
            // No image path set, no image to load
            return
        }
        print("[\(self.title)] Loading thumbnail...")
        JFUtils.loadImage(urlString: JFUtils.getTMDBImageURL(path: imagePath)) { image in
            // Only update, if the image is not nil, dont delete existing images
            if let image = image {
                let thumbnail = Thumbnail(context: self.managedObjectContext!, pngData: image.pngData())
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail
                    PersistenceController.saveContext()
                }
            }
        }
    }
    
    /// Updates the media object with the given data
    /// - Parameter tmdbData: The new data
    func update(tmdbData: TMDBData) throws {
        // Set all TMDBData properties again
        self.initMedia(type: type, tmdbData: tmdbData)
        try self.managedObjectContext?.save()
    }
    
    func missingInformation() -> Set<MediaInformation> {
        var missing: Set<MediaInformation> = []
        if personalRating == .noRating {
            missing.insert(.rating)
        }
        if watchAgain == nil {
            missing.insert(.watchAgain)
        }
        if tags.isEmpty {
            missing.insert(.tags)
        }
        return missing
    }
}

extension Media {
    /// Represents a user-provided information about a media object.
    /// This enum only contains the information, that will cause the object to show up in the Problems tab, when missing
    public enum MediaInformation: String, CaseIterable, Codable {
        case rating
        case watched
        case watchAgain
        case tags
        // Notes are not required for the media object to be complete
    }
    
    enum MediaError: Error {
        case noData
        case encodingFailed(String)
    }
}
