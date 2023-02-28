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
    @Published private var loadedThumbnail: UIImage?
    // The thumbnail will be loaded from disk only when it is first accessed
    var thumbnail: UIImage? {
        get {
            if loadedThumbnail == nil {
                loadedThumbnail = loadThumbnailFromDisk()
            }
            return loadedThumbnail
        }
        set {
            objectWillChange.send()
            loadedThumbnail = newValue
        }
    }
    
    override public var description: String {
        "Media(id: \(id?.uuidString ?? "nil"), title: \(title), rating: \(personalRating.rawValue), watchAgain: " +
        "\(self.watchAgain?.description ?? "nil"), tags: \(tags.map(\.name)))"
    }
    
    override public func prepareForDeletion() {
        // TODO: Title seems to already be empty at this point
        // TODO: Use new poster entity to delete the thumbnail (using the media UUID as filename)
        print("Preparing \(title) for deletion")
        if
            let imagePath,
            let imageURL = Utils.imageFileURL(path: imagePath)
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
        Task {
            // TODO: Reactivate
            //await self.loadThumbnail()
        }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        print("[\(title)] Awaking from insert")
        tags = []
        // TODO: Maybe consider using `setPrimitiveValue` here to avoid sending notifications
        creationDate = Date()
        modificationDate = Date()
    }
    
    override public func willSave() {
        // Changing properties in this function will invoke willSave again.
        // We need to make sure we don't result in a infinite loop
        if (modificationDate?.distance(to: .now) ?? 100.0) > 10.0 {
            // TODO: Use setPrimitiveValue to prevent infinite loop and increase performance
            modificationDate = Date()
        }
        
        if isDeleted {
            // TODO: Delete local data here, not in prepareForDeletion(), in case there is a rollback or the context is discarded
            // TODO: We need to find another way to store thumbnails on disk, to prevent deletion in a background/disposable context to delete the thumbnails on disk
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
        // TODO: FIX: Error happening seemingly randomly
        /*
         2023-02-25 01:00:34.677895+0100 Movie DB[83392:11327579] [error] error: illegally invoked -performWithOptions* on dying NSManagedObjectContext at:
             (
             0   CoreData                            0x0000000184548868 -[NSManagedObjectContext(_NSCoreDataSPI) performWithOptions:andBlock:] + 560
             1   CoreData                            0x000000018449118c $sSo22NSManagedObjectContextC8CoreDataE7perform8schedule_xAbCE17ScheduledTaskTypeO_xyKctYaKlFTY0_ + 900
             2   Movie DB                            0x00000001006a0751 $s8Movie_DB5MediaC17downloadThumbnail33_6C2B2FD65E8B52D357497CFEE84243C5LLSo7UIImageCSgyYaFTQ1_ + 1
             3   Movie DB                            0x00000001006a4059 $s8Movie_DB5MediaC13loadThumbnail5forceySb_tYaFyyYaYbcfU2_TQ0_ + 1
             4   Movie DB                            0x00000001006a59f1 $s8Movie_DB5MediaC13loadThumbnail5forceySb_tYaFyyYaYbcfU2_TATQ0_ + 1
             5   Movie DB                            0x0000000100539df9 $sxIeghHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRTQ0_ + 1
             6   Movie DB                            0x000000010053a065 $sxIeghHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRTATQ0_ + 1
             7   libswift_Concurrency.dylib          0x00000001b03bedcd _ZL23completeTaskWithClosurePN5swift12AsyncContextEPNS_10SwiftErrorE + 1
         )
         */
        // TODO: Restore and fix
        /*
         let loadedPath = await managedObjectContext?.perform {
             self.imagePath
         }
         */
        let loadedPath = managedObjectContext?.performAndWait({ self.imagePath })
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
    
    func loadThumbnail(force: Bool = false) async {
        guard loadedThumbnail == nil || force else {
            // Thumbnail already present, don't load/download again, unless force parameter is given
            return
        }
        let loadedPath = await managedObjectContext?.perform {
            self.imagePath
        }
        guard let imagePath = loadedPath, !imagePath.isEmpty else {
            // No image path set means no image to load
            return
        }
        // If the image is on deny list, delete it and don't reload
        guard !Utils.posterDenyList.contains(imagePath) else {
            print("[\(title)] Thumbnail is on deny list. Purging now.")
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
            print("[\(title)] Downloading thumbnail...")
            Task {
                let image = await downloadThumbnail()
                await MainActor.run {
                    // Use the custom property to invoke the objectWillChange.send()
                    self.thumbnail = image
                }
                // Save the downloaded file
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
