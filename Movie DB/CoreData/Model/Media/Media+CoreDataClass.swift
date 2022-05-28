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
    @Published private var _thumbnail: UIImage?
    // The thumbnail will be loaded from disk only when it is first accessed
    var thumbnail: UIImage? {
        get {
            if _thumbnail == nil {
                self._thumbnail = loadThumbnailFromDisk()
            }
            return self._thumbnail
        }
        set {
            self.objectWillChange.send()
            self._thumbnail = newValue
        }
    }
    
    override public func prepareForDeletion() {
        print("Preparing \(self.title) for deletion")
        if
            let imagePath = self.imagePath,
            let imageURL = Utils.imageFileURL(path: imagePath),
            FileManager.default.fileExists(atPath: imageURL.path)
        {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                print("Error deleting thumbnail on NSManagedObject deletion: \(error)")
            }
        }
    }
    
    // MARK: - Missing Information
    
    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
        print("calling initMedia")
        self.personalRating = .noRating
        self.tags = []
        
        // Assign a new UUID
        self.id = UUID()
        self.type = type
        
        setTMDBData(tmdbData)
        
        // Load the thumbnail from disk or network
        Task {
            await loadThumbnail()
        }
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
            self.tagline = tmdbData.tagline
            self.status = tmdbData.status
            self.originalLanguage = tmdbData.originalLanguage
            self.productionCompanies = Set(self.transferIntoContext(tmdbData.productionCompanies))
            self.homepageURL = tmdbData.homepageURL
            self.productionCountries = tmdbData.productionCountries
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
    
    override public func awakeFromFetch() {
        print("[\(self.title)] Awaking from fetch")
        Task {
            await self.loadThumbnail()
        }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        print("[\(self.title)] Awaking from insert")
        self.castMembersSortOrder = []
        self.tags = []
        self.creationDate = Date()
        self.modificationDate = Date()
    }
    
    override public func willSave() {
        // Changing properties in this function will invoke willSave again.
        // We need to make sure we don't result in a infinite loop
        if (modificationDate?.distance(to: .now) ?? 100.0) > 10.0 {
            self.modificationDate = Date()
        }
    }
    
    // MARK: - Functions
    
    private func loadThumbnailFromDisk() -> UIImage? {
        guard
            let imagePath = imagePath,
            let fileURL = Utils.imageFileURL(path: imagePath),
            FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func downloadThumbnail() async -> UIImage? {
        guard let imagePath = imagePath else {
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
    
    func loadThumbnail(force: Bool = false) async {
        guard thumbnail == nil || force else {
            // Thumbnail already present, don't load/download again, unless force parameter is given
            return
        }
        guard let imagePath = imagePath, !imagePath.isEmpty else {
            // No image path set means no image to load
            return
        }
        // If the image is on deny list, delete it and don't reload
        guard !Utils.posterDenyList.contains(imagePath) else {
            print("[\(self.title)] Thumbnail is on deny list. Purging now.")
            if let imageFile = Utils.imageFileURL(path: imagePath) {
                try? FileManager.default.removeItem(at: imageFile)
            }
            await MainActor.run {
                self.thumbnail = nil
            }
            return
        }
        
        // If the image exists on disk (and the force parameter is false), use the cached version
        if
            let fileURL = Utils.imageFileURL(path: imagePath),
            FileManager.default.fileExists(atPath: fileURL.path),
            !force,
            // If the thumbnail cannot be loaded (e.g. corrupt file), download again too
            let loadedFromDisk = loadThumbnailFromDisk()
        {
            // Load from disk
            await MainActor.run {
                self.thumbnail = loadedFromDisk
            }
        } else {
            // If the image does not exist, is corrupted or the force parameter is given, download it
            print("[\(self.title)] Downloading thumbnail...")
            Task {
                let image = await downloadThumbnail()
                await MainActor.run {
                    self.thumbnail = image
                }
                if let fileURL = Utils.imageFileURL(path: imagePath) {
                    Task {
                        let data = image?.jpegData(compressionQuality: 0.8)
                        do {
                            try data?.write(to: fileURL)
                        } catch {
                            print("Error saving downloaded thumbnail to disk: \(error)")
                        }
                    }
                }
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
