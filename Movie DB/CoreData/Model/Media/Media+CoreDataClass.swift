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
            self.watchProviders = tmdbData.watchProviders
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
        self.watchProviders = []
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
            await MainActor.run {
                self.thumbnail = Thumbnail(
                    context: self.managedObjectContext!,
                    pngData: UIImage(named: "PosterPlaceholder")?.pngData()
                )
            }
            return
        }
        print("[\(self.title)] Loading thumbnail...")
        
        // Load the thumbnail
        Task {
            // We try to load the image, but fail silently if we don't succeed.
            // No need to spam the user with error messages, he will see that the images did not load
            // and no need to delete any existing images on failure.
            do {
                let url = Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.thumbnailTMDBSize)
                let (data, response) = try await URLSession.shared.data(from: url)
                // Only continue if we got a valid response
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    200...299 ~= httpResponse.statusCode
                else {
                    return
                }
                guard let imageData = UIImage(data: data)?.pngData() else {
                    // Unable to construct image
                    return
                }
                // Create the Thumbnail object on the correct thread
                await self.managedObjectContext!.perform {
                    let thumbnail = Thumbnail(context: self.managedObjectContext!, pngData: imageData)
                    // We don't need to set this on the main actor, since we could be on a background thread loading some disposable data.
                    // We just use the MOC thread, which will be the main thread anyways, in case we are dealing with models diesplayed in the view
                    self.thumbnail = thumbnail
                }
            } catch {
                print("Error loading thumbnail: \(error)")
                // Fail silently
                return
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
