//
//  Media+CoreDataClass.swift
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
import os.log
import SwiftUI
import UIKit

/// Represents a media object in the library
@objc(Media)
public class Media: NSManagedObject {
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id?.uuidString ?? "nil"), title: \(title), " +
            "rating: \(personalRating.rawValue), watchAgain: " +
            "\(self.watchAgain?.description ?? "nil"), tags: \(tags.map(\.name)))"
        }
    }
    
    @Published private(set) var thumbnail: UIImage?
    @Published private(set) var backdropImage: UIImage?

    // The task responsible for (down-)loading the thumbnail
    private var loadThumbnailTask: Task<Void, Never>?
    private var loadBackdropTask: Task<Void, Never>?

    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
        self.type = type
        setTMDBData(tmdbData)
        
        // Load the thumbnail from disk or network
        loadImages()
    }
    
    deinit {
        loadThumbnailTask?.cancel()
        loadBackdropTask?.cancel()
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
            self.imdbID = tmdbData.imdbID
            self.keywords = tmdbData.keywords
            self.translations = tmdbData.translations
            self.videos = Set(managedObjectContext.importDummies(tmdbData.videos))
            if let rating = tmdbData.parentalRating {
                self.parentalRating = managedObjectContext.importDummy(rating)
            }
            self.watchProviders = Set(managedObjectContext.importDummies(tmdbData.watchProviders))
            // Also called for the initial load
            self.lastUpdated = .now
        }
    }
    
    func transferIntoContext<T: NSManagedObject>(_ objects: [T]) -> [T] {
        // Make sure to use the objects from the correct context
        // swiftlint:disable:next force_cast
        objects.map { managedObjectContext!.object(with: $0.objectID) as! T }
    }
    
    /// Updates the media object with the given data
    /// - Parameter tmdbData: The new data
    func update(tmdbData: TMDBData) {
        setTMDBData(tmdbData)
    }
    
    // MARK: - MediaInformation (Problems)
    
    /// Returns all `MediaInformation` that is missing on this media object
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
    
    @objc
    func getNextOrLatestReleaseDate() -> Date? {
        assertionFailure("Implement in subclasses!")
        return nil
    }

    func waitForThumbnailDownload() async {
        if let loadThumbnailTask {
            _ = await loadThumbnailTask.value
        }
    }
}

// MARK: - Core Data

public extension Media {
    override func awakeFromFetch() {
        super.awakeFromFetch()
        // Generate a new ID, if the existing one is nil
        if self.id == nil {
            self.id = UUID()
        }
        self.loadImages()
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        Logger.coreData.debug(
            // swiftlint:disable:next line_length
            "[\(self.title, privacy: .public)] Awaking from insert (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
        )
        
        self.id = UUID()
        self.personalRating = .noRating
        self.tags = []
        self.creationDate = .now
        self.modificationDate = .now
    }
    
    override func willSave() {
        updateModificationDate()
        
        if isDeleted {
            // Delete local data here, not in prepareForDeletion()
            // This way, if there is a rollback or the context is discarded, we avoid deleting resources that we still need
            deleteThumbnailOnDisk()
        }
    }
    
    /// Updates the modificationDate of this media, if the current update represents a valid change in properties that should trigger a new modificationDate
    private func updateModificationDate() {
        // Only react to inserts and updates
        guard !isDeleted else { return }
        let changedProperties = self.changedValues().keys
        
        // If the change is containing a modificationDate, don't update again to...
        // a) prevent willSave loops
        // b) not update the modificationDate for changes synced from another device
        // Otherwise, we only update the date if a user-ediable property changed
        // to prevent updating the modification date on automatic background updates.
        guard
            !changedProperties.contains(Schema.Media.modificationDate.rawValue),
            !Set(changedProperties).isDisjoint(with: Schema.Media.userDataKeys.map(\.rawValue))
        else {
            return
        }
        
        setPrimitiveValue(Date.now, forKey: Schema.Media.modificationDate.rawValue)
    }
    
    /// Tries to delete this media's thumbnail on disk
    private func deleteThumbnailOnDisk() {
        Logger.coreData.debug(
            "Deleting \(self.title, privacy: .public) (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
        )
        if let id = self.id {
            do {
                Logger.fileSystem.debug("Deleting thumbnail for media \(id.uuidString, privacy: .public)")
                try Utils.deleteImage(for: id)
            } catch {
                Logger.coreData.warning(
                    // swiftlint:disable:next line_length
                    "[\(self.title, privacy: .public)] Error deleting thumbnail: \(error) (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
                )
            }
        }
    }
}

// MARK: - Thumbnail

extension Media {
    /// Loads this `Media`'s poster thumbnail from disk or the internet and assigns it to the `thumbnail` property
    /// - Parameter force: If set to `true`, downloads the poster thumbnail from the internet even if there already exists a `thumbnail` set or a matching thumbnail on disk.
    func loadImages(force: Bool = false) {
        loadThumbnail(force: force)
    }

    private func loadThumbnail(force: Bool = false) {
        var mediaID: Media.ID?
        var imagePath: String?
        managedObjectContext?.performAndWait {
            mediaID = self.id
            imagePath = self.imagePath
        }
        guard let mediaID else { return }
        loadImage(
            path: imagePath,
            mediaID: mediaID,
            in: \.loadThumbnailTask,
            store: \.thumbnail,
            force: force,
            imageService: .mediaThumbnails
        )
    }
    
    private func loadImage(
        path imagePath: String?,
        mediaID: Media.ID,
        in taskKeyPath: ReferenceWritableKeyPath<Media, Task<Void, Never>?>,
        store imageKeyPath: ReferenceWritableKeyPath<Media, UIImage?>,
        force: Bool = false,
        imageService: TMDBImageService
    ) {
        // !!!: Use lots of Task.isCancelled to make sure this media object still exists during execution,
        // !!!: otherwise accessing e.g. the unowned managedObjectContext property crashes the app
        // Already loading the image
        if let task = self[keyPath: taskKeyPath] {
            // Don't restart the backdrop loading and let the current task finish
            guard force else { return }

            // Cancel and restart
            Logger.coreData.debug(
                "Restarting backdrop download for media \(self.id?.uuidString ?? "nil", privacy: .public)"
            )
            task.cancel()
        }

        // Start loading the image
        // Use a dedicated overall task to be able to cancel it
        self[keyPath: taskKeyPath] = Task(priority: .high) { [managedObjectContext] in
            do {
                try Task.checkCancellation()

                // We need to access the properties on the managedObjectContext's thread
                await managedObjectContext?.perform {
                    guard force || self[keyPath: imageKeyPath] == nil else {
                        // Image already present or no context, don't load/download again, unless force parameter is given
                        return
                    }
                }

                try Task.checkCancellation()

                Task { [mediaID, imagePath] in
                    try Task.checkCancellation()

                    do {
                        // TODO: Rename function
                        let image = try await imageService.thumbnail(
                            for: mediaID,
                            imagePath: imagePath,
                            force: force
                        )
                        try Task.checkCancellation()
                        await managedObjectContext?.perform {
                            self.objectWillChange.send()
                            self[keyPath: imageKeyPath] = image
                        }
                    } catch {
                        Logger.coreData.warning(
                            // swiftlint:disable:next line_length
                            "[\(self.title, privacy: .public)] Error (down-)loading image: \(error) (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
                        )
                    }
                }
            } catch {
                Logger.network.error("Error downloading image: \(error)")
            }
        }
    }
}
