//
//  Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CloudKit
import Combine
import CoreData
import Foundation
import JFSwiftUI
import SwiftUI
import UIKit

/// Represents a media object in the library
@objc(Media)
public class Media: NSManagedObject {
    @Published private(set) var thumbnail: UIImage?
    
    // Loads the poster thumbnail in the background and assigns it to this media's thumbnail property
    func loadThumbnail(force: Bool = false) async {
        guard force || managedObjectContext?.performAndWait({ self.thumbnail }) == nil else {
            // Thumbnail already present, don't load/download again, unless force parameter is given
            return
        }
        do {
            let mediaID = managedObjectContext?.performAndWait { self.id }
            let imagePath = managedObjectContext?.performAndWait { self.imagePath }
            let thumbnail = try await PosterService.shared.thumbnail(for: mediaID, imagePath: imagePath, force: force)
            assert(self.managedObjectContext != nil)
            self.managedObjectContext?.performAndWait {
                self.objectWillChange.send()
                self.thumbnail = thumbnail
            }
        } catch {
            print("Error downloading thumbnail: \(error)")
        }
    }
    
    override public var description: String {
        "Media(id: \(id?.uuidString ?? "nil"), title: \(title), rating: \(personalRating.rawValue), watchAgain: " +
        "\(self.watchAgain?.description ?? "nil"), tags: \(tags.map(\.name)))"
    }
    
    // MARK: - Missing Information
    
    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
        print("calling initMedia")
        // TODO: We could do this in awakeFromInsert
        personalRating = .noRating
        tags = []
        
        // Assign a new UUID
        id = UUID()
        self.type = type
        
        setTMDBData(tmdbData)
        
        // Load the thumbnail from disk or network
        Task {
            await loadThumbnail()
        }
    }
    
    private func setTMDBData(_ tmdbData: TMDBData) {
        guard let managedObjectContext else {
            assertionFailure()
            return
        }
        
        managedObjectContext.performAndWait {
            // Set all properties from the tmdbData object
            self.tmdbID = tmdbData.id
            self.title = tmdbData.title
            self.originalTitle = tmdbData.originalTitle
            self.imagePath = tmdbData.imagePath
            self.genres = Set(managedObjectContext.importDummies(tmdbData.genres))
            self.overview = tmdbData.overview
            self.tagline = tmdbData.tagline
            self.status = tmdbData.status
            self.originalLanguage = tmdbData.originalLanguage
            self.productionCompanies = Set(managedObjectContext.importDummies(tmdbData.productionCompanies))
            self.homepageURL = tmdbData.homepageURL
            self.productionCountries = tmdbData.productionCountries
            self.popularity = tmdbData.popularity
            self.voteAverage = tmdbData.voteAverage
            self.voteCount = tmdbData.voteCount
            self.keywords = tmdbData.keywords
            self.translations = tmdbData.translations
            self.videos = Set(managedObjectContext.importDummies(tmdbData.videos))
            self.parentalRating = tmdbData.parentalRating
            self.watchProviders = tmdbData.watchProviders
        }
    }
    
    func transferIntoContext<T: NSManagedObject>(_ objects: [T]) -> [T] {
        // Make sure to use the objects from the correct context
        // swiftlint:disable:next force_cast
        objects.map { managedObjectContext!.object(with: $0.objectID) as! T }
    }
    
    override public func awakeFromFetch() {
        super.awakeFromFetch()
        Task {
            await self.loadThumbnail()
        }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        print("[\(title)] Awaking from insert")
        tags = []
        // Use `setPrimitiveValue` to avoid sending notifications
        setPrimitiveValue(Date(), forKey: "creationDate")
        setPrimitiveValue(Date(), forKey: "modificationDate")
    }
    
    override public func willSave() {
        // Use `setPrimitiveValue` to avoid sending notifications
        setPrimitiveValue(Date(), forKey: "modificationDate")
        
        if isDeleted {
            // Delete local data here, not in prepareForDeletion(), in case there is a rollback or the context is discarded
            print("Deleting \(title)...")
            if let id = self.id {
                do {
                    try Utils.deleteImage(for: id)
                } catch {
                    print("Error deleting thumbnail: \(error)")
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadThumbnailFromDisk() -> UIImage? {
        // TODO: Fix: We are not on the moc's thread, but are accessing its properties (imagePath),
        // probably need to make this function async
        // When accessing the imagePath, we should be on the same thread as the managedObjectContext
        guard
            let imagePath = self.managedObjectContext?.performAndWait({ self.imagePath }),
            let fileURL = Utils.imageFileURL(path: imagePath),
            FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func downloadThumbnail() async -> UIImage? {
        guard !Task.isCancelled else {
            return nil
        }
        let loadedPath = managedObjectContext?.performAndWait { self.imagePath }
        guard let imagePath = loadedPath else {
            return nil
        }
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
                return nil
            }
            return UIImage(data: data)
        } catch {
            print("Error loading thumbnail: \(error)")
            // Fail silently
            return nil
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
        
        var localized: String {
            switch self {
            case .rating:
                return Strings.MediaInformation.rating
            case .watched:
                return Strings.MediaInformation.watched
            case .watchAgain:
                return Strings.MediaInformation.watchAgain
            case .tags:
                return Strings.MediaInformation.tags
            }
        }
    }
    
    enum MediaError: Error {
        case noData
        case encodingFailed(String)
    }
}
