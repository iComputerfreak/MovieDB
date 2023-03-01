//
//  PosterService.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

/// An actor, resposible for downloading and caching media posters from themoviedatabase.org
actor PosterService {
    static let shared = PosterService()
    
    private var activeDownloads: [UUID: Task<UIImage, Error>] = [:]
    
    func thumbnail(for media: Media, force: Bool = false) async throws -> UIImage? {
        // TODO: Probably error with "dying NSManagedObjectContext" again? Maybe access unsynchronized (its just read)
        guard
            let mediaID = await media.managedObjectContext?.perform({ media.id }),
            let fileURL = Utils.imageFileURL(for: mediaID),
            let imagePath = await media.managedObjectContext?.perform({ media.imagePath }),
            !imagePath.isEmpty
        else {
            // No thumbnail to load
            return nil
        }
        
        // If the image is on deny list, delete it and don't reload
        guard !Utils.posterDenyList.contains(imagePath) else {
            print("[\(media.title)] Thumbnail is on deny list. Purging now.")
            try? Utils.deleteImage(for: mediaID)
            return nil
        }
        
        // Check if there is already a download in progress
        if let task = activeDownloads[mediaID] {
            // Return the result once it's available
            return try await task.value
        }
        
        // Check if the image already exists on disk (does not matter if force is true)
        if !force, FileManager.default.fileExists(atPath: fileURL.path()) {
            // File already downloaded, return the file on disk
            return UIImage(data: try Data(contentsOf: fileURL))
        } else {
            // Download the poster image in thumbnail size
            let downloadTask = Task {
                let webURL = Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.thumbnailTMDBSize)
                return try await Utils.loadImage(from: webURL)
            }
            
            // Add the task to the activeDownloads to prevent downloading images twice
            activeDownloads[mediaID] = downloadTask
            
            // Wait for the task to finish
            let result = try await downloadTask.value
            
            // Save the image to disk for further requests
            do {
                try result.pngData()?.write(to: fileURL)
                activeDownloads[mediaID] = nil
            } catch {
                // Error saving the image to disk, we will need to download it again next time
                print("Error saving image to disk: \(mediaID)")
            }
            
            // Return the downloaded image
            return result
        }
    }
}
