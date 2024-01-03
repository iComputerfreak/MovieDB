//
//  TMDBImageService.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

/// An actor, resposible for downloading and caching media posters from themoviedatabase.org
actor TMDBImageService {
    static let mediaThumbnails = TMDBImageService(imageSize: JFLiterals.thumbnailTMDBSize)
    static let watchProviderLogos = TMDBImageService(imageSize: nil)
    
    let imageSize: Int?
    
    private var activeDownloads: [AnyHashable: Task<UIImage, Error>] = [:]
    
    /// Creates a new `TMDBImageService`
    /// - Parameter thumbnailSize: The size as used by the TMDB API for fetching the thumbnail
    init(imageSize: Int?) {
        self.imageSize = imageSize
    }
    
    /// A convenience overload for ``image(for:to:downloadID:force:)-c3uo``
    func thumbnail(for mediaID: UUID?, imagePath: String?, force: Bool = false) async throws -> UIImage? {
        guard let mediaID else {
            return nil
        }
        return try await image(for: imagePath, to: Utils.imageFileURL(for: mediaID), downloadID: mediaID)
    }
    
    /// A convenience overload for ``image(for:to:downloadID:force:)-c3uo`` using an optional imagePath.
    func image(
        for imagePath: String?,
        to fileURL: URL? = nil,
        downloadID: AnyHashable,
        force: Bool = false
    ) async throws -> UIImage? {
        guard let imagePath, !imagePath.isEmpty else {
            return nil
        }
        return try await image(for: imagePath, to: fileURL, downloadID: downloadID, force: force)
    }
    
    /// Loads an image from the given `fileURL` or downloads it using the given `imagePath`
    ///
    /// This function checks if the given `fileURL` points to an image on disk. If it does, the function returns that image.
    /// If the fileURL does not point to an image on disk, this function downloads the image using the provided `imagePath`.
    /// The resulting image is then stored at the given `fileURL` and returned.
    ///
    /// If `fileURL` is `nil`, the image will be downloaded and returned every time, instead of being cached.
    ///
    /// If an image is requested using this funtion while it is already being downloaded, the running download will be awaited and the result returned.
    ///
    /// - Parameters:
    ///   - imagePath: The TMDB API image path that specifies the internet location where to get the image from
    ///   - fileURL: An optional URL to a file on disk that is used to load an already cached file and save a downloaded image
    ///   - downloadID: A unique ID for this download (e.g. `Media.id`)
    ///   - force: Whether to download the image regardless of whether it already exists on disk
    /// - Returns: The (down-)loaded image
    func image(
        for imagePath: String,
        to fileURL: URL? = nil,
        downloadID: AnyHashable,
        force: Bool = false
    ) async throws -> UIImage? {
        // If the image is on deny list, delete it and don't reload
        guard !Utils.posterDenyList.contains(imagePath) else {
            if let fileURL {
                Logger.imageService.warning("[\(downloadID, privacy: .public)] Image is on deny list. Purging now.")
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path()) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                } catch {
                    Logger.imageService.error("Error deleting image on deny list: \(error, privacy: .public)")
                }
            }
            return nil
        }
        
        // Check if there is already a download in progress
        if let task = activeDownloads[downloadID] {
            // Return the result once it's available
            return try await task.value
        }
        
        // Check if the image already exists on disk (does not matter if force is true)
        if let fileURL, !force, FileManager.default.fileExists(atPath: fileURL.path()) {
            // File already downloaded, return the file on disk
            return try UIImage(data: Data(contentsOf: fileURL))
        } else {
            // Download the poster image in thumbnail size
            let downloadTask = Task {
                Logger.imageService.debug(
                    "Downloading image for downloadID \(String(describing: downloadID), privacy: .public)"
                )
                guard let webURL = Utils.getTMDBImageURL(path: imagePath, size: imageSize) else {
                    Logger.imageService.error("Unable to get TMDB image URL for imagePath '\(imagePath)'")
                    return UIImage.posterPlaceholder
                }
                return try await Utils.loadImage(from: webURL)
            }
            
            // Add the task to the activeDownloads to prevent downloading images twice
            activeDownloads[downloadID] = downloadTask
            
            // Wait for the task to finish
            let result = try await downloadTask.value
            
            // Save the image to disk for later requests
            if let fileURL {
                do {
                    try result.pngData()?.write(to: fileURL)
                } catch {
                    // Error saving the image to disk, we will need to download it again next time
                    Logger.imageService.error(
                        "[\(downloadID, privacy: .public)] Error saving image to disk: \(error, privacy: .public)"
                    )
                }
            }
            
            activeDownloads[downloadID] = nil
            
            // Return the downloaded image
            return result
        }
    }
}
