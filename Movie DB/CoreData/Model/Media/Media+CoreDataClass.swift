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
        
        // Assign a new UUID
        self.id = UUID()
        self.type = type
        
        setTMDBData(tmdbData)
    }
    
    private func setTMDBData(_ tmdbData: TMDBData) {
        managedObjectContext!.performAndWait {
            // The castMembersSortOrder array contains the sorted CastMember IDs
            self.castMembersSortOrder = tmdbData.cast.map(\.id)
            
            // Set all properties from the tmdbData object
            self.tmdbID = tmdbData.id
            self.title = tmdbData.title
            self.originalTitle = tmdbData.originalTitle
            self.imagePath = tmdbData.imagePath
            self.genres = Set(self.transferIntoContext(tmdbData.genres))
            self.overview = tmdbData.overview
            self.status = tmdbData.status
            self.originalLanguage = tmdbData.originalLanguage
            self.productionCompanies = Set(self.transferIntoContext(tmdbData.productionCompanies))
            self.homepageURL = tmdbData.homepageURL
            self.popularity = tmdbData.popularity
            self.voteAverage = tmdbData.voteAverage
            self.voteCount = tmdbData.voteCount
            self.cast = Set(self.transferIntoContext(tmdbData.cast))
            self.keywords = tmdbData.keywords
            self.translations = tmdbData.translations
            self.videos = Set(self.transferIntoContext(tmdbData.videos))
            self.parentalRating = tmdbData.parentalRating
        }
    }
    
    func transferIntoContext<T: NSManagedObject>(_ objects: [T]) -> [T] {
        // Make sure to use the objects from the correct context
        // swiftlint:disable:next force_cast
        return objects.map { managedObjectContext!.object(with: $0.objectID) as! T }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.castMembersSortOrder = []
        self.tags = []
        self.creationDate = Date()
        self.modificationDate = Date()
    }
    
    override public func willSave() {
        // Changing properties in this function will invoke willSave again.
        // We need to make sure we don't result in a infinite loop
        if modificationDate.timeIntervalSince(Date()) > 10.0 {
            self.modificationDate = Date()
        }
    }
    
    // MARK: - Functions
    
    // TODO: Loading is not happening on background thread, but async. Problem?
    func loadThumbnail(force: Bool = false) async {
        guard thumbnail == nil || force else {
            // Thumbnail already present, don't download again, unless force parameter is given
            return
        }
        guard let imagePath = imagePath, !imagePath.isEmpty else {
            // No image path set means no image to load
            return
        }
        // If the image is on deny list, delete it and don't reload
        guard !Utils.posterDenyList.contains(imagePath) else {
            print("[\(self.title)] Thumbnail is on deny list. Will not load.")
            // Use the placeholder image instead
            self.thumbnail = Thumbnail(
                context: self.managedObjectContext!,
                pngData: UIImage(named: "PosterPlaceholder")?.pngData()
            )
            return
        }
        print("[\(self.title)] Loading thumbnail...")
        
        // Fail silently and just now show the image
        // Only update, if the loaded image is not nil, dont delete existing images
        if let image = try? await Utils.loadImage(with: imagePath, size: JFLiterals.thumbnailTMDBSize) {
            assert(self.managedObjectContext != nil)
            let thumbnail = Thumbnail(context: self.managedObjectContext!, pngData: image.pngData())
            await MainActor.run {
                self.thumbnail = thumbnail
            }
        }
    }
    
    /// Updates the media object with the given data
    /// - Parameter tmdbData: The new data
    func update(tmdbData: TMDBData) {
        setTMDBData(tmdbData)
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
