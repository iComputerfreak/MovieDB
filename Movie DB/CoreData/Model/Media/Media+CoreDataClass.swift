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
import os.log
import SwiftUI
import UIKit

/// Represents a media object in the library
@objc(Media)
public class Media: NSManagedObject {
    @Published private(set) var thumbnail: UIImage?
    
    override public var description: String {
        "Media(id: \(id?.uuidString ?? "nil"), title: \(title), rating: \(personalRating.rawValue), watchAgain: " +
        "\(self.watchAgain?.description ?? "nil"), tags: \(tags.map(\.name)))"
    }
    
    // MARK: - Missing Information
    
    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
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
        // Generate a new ID, if the existing one is nil
        if self.id == nil {
            self.id = UUID()
        }
        Task {
            await self.loadThumbnail()
        }
    }
    
    override public func awakeFromInsert() {
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
    
    override public func willSave() {
        // Use `setPrimitiveValue` to avoid sending notifications
        setPrimitiveValue(Date(), forKey: Schema.Media.modificationDate.rawValue)
        
        if isDeleted {
            // Delete local data here, not in prepareForDeletion()
            // This way, if there is a rollback or the context is discarded, we avoid deleting resources that we still need
            Logger.coreData.debug(
                // swiftlint:disable:next line_length
                "Deleting \(self.title, privacy: .public)... (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
            )
            if let id = self.id {
                do {
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
    
    // MARK: - Functions
    
    /// Loads this `Media`'s poster thumbnail from disk or the internet and assigns it to the `thumbnail` property
    /// - Parameter force: If set to `true`, downloads the poster thumbnail from the internet even if there already exists a `thumbnail` set or a matching thumbnail on disk.
    func loadThumbnail(force: Bool = false) async {
        guard
            let managedObjectContext,
            force || managedObjectContext.performAndWait({ self.thumbnail }) == nil
        else {
            // Thumbnail already present or no context, don't load/download again, unless force parameter is given
            return
        }
        do {
            let mediaID = managedObjectContext.performAndWait { self.id }
            let imagePath = managedObjectContext.performAndWait { self.imagePath }
            let thumbnail = try await PosterService.shared.thumbnail(for: mediaID, imagePath: imagePath, force: force)
            managedObjectContext.performAndWait {
                self.objectWillChange.send()
                self.thumbnail = thumbnail
            }
        } catch {
            Logger.coreData.warning(
                // swiftlint:disable:next line_length
                "[\(self.title, privacy: .public)] Error (down-)loading thumbnail: \(error) (mediaID: \(self.id?.uuidString ?? "nil", privacy: .public))"
            )
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
