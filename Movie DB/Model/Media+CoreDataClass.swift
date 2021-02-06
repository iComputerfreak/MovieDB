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
    
    // TODO: Copy didSet over
    /*@Published var personalRating: StarRating = .noRating {
        didSet {
            if personalRating == .noRating {
                // Rating is missing now
                self.missingInformation.insert(.rating)
            } else {
                // Rating is not missing anymore
                self.missingInformation.remove(.rating)
            }
        }
    }*/
    
    // TODO: Copy didSet over
    /*
    @Published var tags: [Int] = [] {
        didSet {
            if tags == [] {
                self.missingInformation.insert(.tags)
            } else {
                self.missingInformation.remove(.tags)
            }
        }
    }
 */
    
    
    // MARK: - Missing Information
    
    /// Initialize all Media properties from the given TMDBData
    /// Call this function from `Show.init` or `Movie.init` to properly set up the common properties
    func initMedia(type: MediaType, tmdbData: TMDBData) {
        self.personalRating = .noRating
        
        // TODO: Add assertion (e.g. type(of: self) == Movie.self or Show.self)
        self.id = Int64(MediaID.nextID)
        self.type = type
        // Set all properties from the tmdbData object
        self.tmdbID = Int64(tmdbData.id)
        self.title = tmdbData.title
        self.originalTitle = tmdbData.originalTitle
        self.imagePath = tmdbData.imagePath
        // TODO: self.genres = tmdbData.genres
        self.overview = tmdbData.overview
        self.status = tmdbData.status
        self.originalLanguage = tmdbData.originalLanguage
        // TODO: self.productionCompanies = tmdbData.productionCompanies
        self.homepageURL = tmdbData.homepageURL
        self.popularity = tmdbData.popularity
        self.voteAverage = tmdbData.voteAverage
        self.voteCount = Int64(tmdbData.voteCount)
        // TODO: self.cast = tmdbData.cast
        self.keywords = tmdbData.keywords
        self.translations = tmdbData.translations
        // TODO: self.videos = tmdbData.videos
    }
    
    
    
    
    //@Published var missingInformation: Set<MediaInformation> = Set(MediaInformation.allCases)
    // TODO: Init value
    
    // MARK: - Functions
    
    /// Triggers a reload of the thumbnail using the `imagePath` in `tmdbData`
    func loadThumbnail(force: Bool = false) {
        guard thumbnail == nil || force else {
            // Thumbnail already present, don't download again, override with force parameter
            return
        }
        guard let imagePath = imagePath, !imagePath.isEmpty else {
            // No image path set, no image to load
            return
        }
        print("[\(self.title)] Loading thumbnail...")
        JFUtils.loadImage(urlString: JFUtils.getTMDBImageURL(path: imagePath)) { image in
            // Only update, if the image is not nil, dont delete existing images
            if let image = image {
                DispatchQueue.main.async {
                    self.thumbnail = image
                }
            }
        }
    }
    
    /// Updates the media object with the given data
    /// - Parameter tmdbData: The new data
    func update(tmdbData: TMDBData) {
        // TODO: Implement
        
    }
    
    
    
    // MARK: - Repairable Conformance
    
    /// Attempts to identify problems and repair this media object by reloading the thumbnail, removing corrupted tags and re-loading the cast information
    /// - Parameter progress: A binding for the progress of the repair status
    /// - Returns: The number of fixed and not fixed problems
    func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        // We have to check the following things:
        // tmdbData, thumbnail, tags, missingInformation
        let progressStep = 1.0/3.0
        let group = DispatchGroup()
        var fixed = 0
        let notFixed = 0
        // If we have no TMDBData, we have no tmdbID and therefore no possibility to reload the data.
        progress?.wrappedValue += progressStep
        // Thumbnail
        if self.thumbnail == nil && imagePath != nil {
            loadThumbnail()
            fixed += 1
            print("[Verify] '\(title)' (\(id)) is missing the thumbnail. Trying to fix it.")
        }
        progress?.wrappedValue += progressStep
        // Tags
        for tag in tags {
            // If the tag does not exist, remove it
            if !TagLibrary.shared.tags.map(\.id).contains(tag) {
                DispatchQueue.main.async {
                    self.tags.removeFirst(tag)
                    fixed += 1
                    print("[Verify] '\(self.title)' (\(self.id)) has invalid tags. Removed the invalid tags.")
                }
            }
        }
        progress?.wrappedValue += progressStep
        // Missing Information
        DispatchQueue.main.async {
            self.missingInformation = .init()
            if self.personalRating == .noRating {
                self.missingInformation.insert(.rating)
            }
            if self.watchAgain == nil {
                self.missingInformation.insert(.watchAgain)
            }
            if self.tags.isEmpty {
                self.missingInformation.insert(.tags)
            }
        }
        progress?.wrappedValue += progressStep
        
        
        // TODO: Check, if tmdbData is complete, nothing is missing (e.g. cast, seasons, translations, keywords, ...)
        
        group.wait()
        // Make sure the progress is 100% (may be less due to rounding errors)
        progress?.wrappedValue = 1.0
        if fixed == 0 && notFixed == 0 {
            return .none
        } else {
            return .some(fixed: fixed, notFixed: notFixed)
        }
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
