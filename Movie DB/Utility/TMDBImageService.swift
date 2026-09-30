// Copyright © 2023 Jonas Frey. All rights reserved.

import Foundation
import ImageIO
import os.log
import SwiftUI

/// An actor, resposible for downloading and caching media posters from themoviedatabase.org
actor TMDBImageService {
    /// Identifies one remote image independently from its decoded size.
    private struct DownloadKey: Hashable {
        let id: AnyHashable
        let imagePath: String
    }

    /// Associates a shared download with a token for race-free cleanup.
    private struct ActiveDownload {
        let token: UUID
        let task: Task<Data?, Error>
    }

    static let mediaThumbnails = TMDBImageService(imageSize: JFLiterals.thumbnailTMDBSize)
    static let backdropImages = TMDBImageService(imageSize: JFLiterals.backdropImageTMDBSize)
    static let watchProviderLogos = TMDBImageService(imageSize: nil)
    
    let imageSize: Int?
    
    private var activeDownloads: [DownloadKey: ActiveDownload] = [:]
    private let decodedImages = NSCache<NSString, UIImage>()
    
    /// Creates a new `TMDBImageService`
    /// - Parameter imageSize: The size used by the TMDB API for fetching images.
    init(imageSize: Int?) {
        self.imageSize = imageSize
        decodedImages.totalCostLimit = 32 * 1_024 * 1_024
    }
    
    /// Loads a media poster using its stable local cache key.
    /// - Parameters:
    ///   - mediaID: Stable library identifier used as the disk-cache key.
    ///   - imagePath: TMDB image path.
    ///   - maxPixelSize: Maximum decoded width or height, or `nil` for source dimensions.
    ///   - force: Whether to replace existing memory and disk cache entries.
    /// - Returns: A decoded image, or `nil` when no image path is available.
    /// - Throws: Network and file-system errors encountered while loading the image.
    func thumbnail(
        for mediaID: UUID?,
        imagePath: String?,
        maxPixelSize: Int? = nil,
        force: Bool = false
    ) async throws -> UIImage? {
        guard let mediaID, let imagePath else { return nil }
        return try await image(
            for: imagePath,
            to: Utils.imageFileURL(for: mediaID),
            // TODO: For some reason, this still causes conflicts when starting the app (updating media)
            downloadID: mediaID,
            maxPixelSize: maxPixelSize,
            force: force
        )
    }

    /// Removes a media poster from both decoded memory and disk caches.
    /// - Parameter mediaID: Stable library identifier used as the disk-cache key.
    /// - Throws: Any file-system error encountered while deleting the poster.
    func removeThumbnail(for mediaID: UUID) throws {
        decodedImages.removeAllObjects()
        let matchingKeys = activeDownloads.keys.filter { $0.id == AnyHashable(mediaID) }
        for key in matchingKeys {
            activeDownloads.removeValue(forKey: key)?.task.cancel()
        }
        try Utils.deleteImage(for: mediaID)
    }
    
    /// Loads an optional image path.
    /// - Parameters:
    ///   - imagePath: Optional TMDB image path.
    ///   - fileURL: Optional disk-cache destination.
    ///   - downloadID: Identifier used to deduplicate concurrent downloads.
    ///   - maxPixelSize: Maximum decoded width or height, or `nil` for source dimensions.
    ///   - force: Whether to replace existing memory and disk cache entries.
    /// - Returns: A decoded image, or `nil` when no image path is available.
    /// - Throws: Network and file-system errors encountered while loading the image.
    func image(
        for imagePath: String?,
        to fileURL: URL? = nil,
        downloadID: AnyHashable,
        maxPixelSize: Int? = nil,
        force: Bool = false
    ) async throws -> UIImage? {
        guard let imagePath, !imagePath.isEmpty else { return nil }
        return try await image(
            for: imagePath,
            to: fileURL,
            downloadID: downloadID,
            maxPixelSize: maxPixelSize,
            force: force
        )
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
    ///   - maxPixelSize: Maximum decoded width or height, or `nil` for source dimensions.
    ///   - force: Whether to download the image regardless of whether it already exists on disk
    /// - Returns: The (down-)loaded image
    /// - Throws: Network and file-system errors encountered while loading the image.
    func image(
        for imagePath: String,
        to fileURL: URL? = nil,
        downloadID: AnyHashable,
        maxPixelSize: Int? = nil,
        force: Bool = false
    ) async throws -> UIImage? {
        let cacheKey = "\(imagePath)|\(maxPixelSize.map(String.init) ?? "original")" as NSString
        let downloadKey = DownloadKey(id: downloadID, imagePath: imagePath)
        if !force, let image = decodedImages.object(forKey: cacheKey) {
            return image
        }

        let data: Data?

        // Check if there is already a download in progress
        if !force, let download = activeDownloads[downloadKey] {
            data = try await download.task.value
        } else if let fileURL, !force, FileManager.default.fileExists(atPath: fileURL.path()) {
            data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        } else {
            activeDownloads.removeValue(forKey: downloadKey)?.task.cancel()
            let downloadTask = Task<Data?, Error> {
                Logger.imageService.debug(
                    "Downloading image for downloadID \(String(describing: downloadID), privacy: .public)"
                )
                guard let webURL = Utils.getTMDBImageURL(path: imagePath, size: imageSize) else {
                    Logger.imageService.error("Unable to get TMDB image URL for imagePath '\(imagePath)'")
                    return nil
                }
                return try await Utils.loadData(from: webURL)
            }

            let token = UUID()
            activeDownloads[downloadKey] = ActiveDownload(token: token, task: downloadTask)
            defer {
                if activeDownloads[downloadKey]?.token == token {
                    activeDownloads[downloadKey] = nil
                }
            }

            data = try await downloadTask.value

            if let fileURL, let data {
                do {
                    try data.write(to: fileURL, options: .atomic)
                } catch {
                    Logger.imageService.error(
                        "[\(downloadID, privacy: .public)] Error saving image to disk: \(error, privacy: .public)"
                    )
                }
            }
        }

        guard let data, let image = Self.decodeImage(data, maxPixelSize: maxPixelSize) else { return nil }
        decodedImages.setObject(image, forKey: cacheKey, cost: Self.decodedCost(of: image))
        return image
    }

    /// Decodes image data, optionally downsampling it to a maximum pixel dimension.
    /// - Parameters:
    ///   - data: Encoded image data.
    ///   - maxPixelSize: Maximum decoded width or height, or `nil` to decode at source dimensions.
    /// - Returns: A decoded image, or `nil` when the data is invalid.
    static func decodeImage(_ data: Data, maxPixelSize: Int?) -> UIImage? {
        guard let maxPixelSize else { return UIImage(data: data) }
        guard let source = CGImageSourceCreateWithData(data as CFData, [
            kCGImageSourceShouldCache: false,
        ] as CFDictionary) else {
            return nil
        }

        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// Returns the decoded bitmap cost used by `NSCache`.
    /// - Parameter image: Decoded image to measure.
    /// - Returns: Approximate decoded byte count.
    private static func decodedCost(of image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
