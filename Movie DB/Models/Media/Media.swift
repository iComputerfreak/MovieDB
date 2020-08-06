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

/// Represents a media object in the library
class Media: Identifiable, ObservableObject, Codable, Hashable {
    
    enum MediaError: Error {
        case noData
        case encodingFailed(String)
    }
    
    // MARK: - Properties
    // Media ID Creation
    /// Contains the next free collection id
    private static var _nextID = 0
    /// Returns the next free library id
    static var nextID: Int {
        print("Requesting new ID.")
        // Initialize
        if _nextID <= 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextID")
            if _nextID == 0 {
                // No id saved in user defaults, lets start at 1
                _nextID = 1
            }
        }
        // Increase _nextID after returning
        defer {
            _nextID += 1
            UserDefaults.standard.set(_nextID, forKey: "nextID")
        }
        print("Returning new ID \(_nextID)")
        return _nextID
    }
    
    /// Resets the nextID property
    static func resetNextID() {
        _nextID = 0
        UserDefaults.standard.set(_nextID, forKey: "nextID")
    }
    
    /// The internal library id
    let id: Int
    /// The data from TMDB
    @Published var tmdbData: TMDBData? = nil
    /// The type of media
    @Published var type: MediaType
    /// A rating between 0 and 10 (no Rating and 5 stars)
    @Published var personalRating: StarRating = .noRating {
        didSet {
            if personalRating == .noRating {
                // Rating is missing now
                self.missingInformation.insert(.rating)
            } else {
                // Rating is not missing anymore
                self.missingInformation.remove(.rating)
            }
        }
    }
    /// A list of user-specified tags, listed by their id
    @Published var tags: [Int] = [] {
        didSet {
            if tags == [] {
                self.missingInformation.insert(.tags)
            } else {
                self.missingInformation.remove(.tags)
            }
        }
    }
    /// Whether the user would watch the media again
    @Published var watchAgain: Bool? = nil {
        didSet {
            if watchAgain == nil {
                self.missingInformation.insert(.watchAgain)
            } else {
                self.missingInformation.remove(.watchAgain)
            }
        }
    }
    /// Personal notes on the media
    @Published var notes: String = ""
    /// The thumbnail image
    @Published var thumbnail: UIImage? = nil
    
    /// Whether the result is a movie and is for adults only
    var isAdult: Bool? { (tmdbData as? TMDBMovieData)?.isAdult }
    
    /// The year of the release or first airing of the media
    var year: Int? {
        var cal = Calendar.current
        cal.timeZone = .utc
        if let movieData = tmdbData as? TMDBMovieData, let releaseDate = movieData.releaseDate {
            return cal.component(.year, from: releaseDate)
        } else if let showData = tmdbData as? TMDBShowData, let airDate = showData.firstAirDate {
            return cal.component(.year, from: airDate)
        }
        return nil
    }
    
    /// Represents a user-provided information about a media object.
    /// This enum only contains the information, that will cause the object to show up in the Problems tab, when missing
    enum MediaInformation: String, CaseIterable {
        case rating
        case watched
        case watchAgain
        case tags
        // Notes are not required for the media object to be complete
        //case notes
    }
    
    /// The set of missing information of this media
    @Published var missingInformation: Set<MediaInformation> = Set(MediaInformation.allCases)
    
    // Only used by constructing subclasses
    
    /// Creates a new `Media` object.
    /// - Important: Only use this initializer on concrete subclasses of `Media`. Never instantiate `Media` itself.
    init(type: MediaType) {
        self.id = Self.nextID
        self.type = type
    }
    
    /// Triggers a reload of the thumbnail using the `imagePath` in `tmdbData`
    func loadThumbnail(force: Bool = false) {
        guard let tmdbData = self.tmdbData else {
            // Function invoked, without tmdbData being initialized
            return
        }
        guard thumbnail == nil || force else {
            // Thumbnail already present, don't download again, override with force parameter
            return
        }
        guard let imagePath = tmdbData.imagePath, !imagePath.isEmpty else {
            // No image path set, no image to load
            return
        }
        print("[\(self.tmdbData?.title ?? "nil")] Loading thumbnail...")
        JFUtils.loadImage(urlString: JFUtils.getTMDBImageURL(path: imagePath)) { image in
            // Only update, if the image is not nil, dont delete existing images
            if let image = image {
                DispatchQueue.main.async {
                    self.thumbnail = image
                }
            }
        }
    }
    
    // MARK: - Codable Conformance
    // Only used for reading/writing from/to disk.
    // Creating the media objects from API Responses creates and fills the media object manually!
    
    /// Tries to create a media object by decoding the data from the given Decoder.
    /// - Parameter decoder: The decoder holding the data for the media object
    /// - Throws: If any of the required data is missing or invalid
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(MediaType.self, forKey: .type)
        self.personalRating = try container.decode(StarRating.self, forKey: .personalRating)
        self.tags = try container.decode([Int].self, forKey: .tags)
        self.watchAgain = try container.decode(Bool?.self, forKey: .watchAgain)
        self.notes = try container.decode(String.self, forKey: .notes)
        let imagePath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(self.id).png")
        if type == .movie {
            self.tmdbData = try container.decodeIfPresent(TMDBMovieData.self, forKey: .tmdbData)
        } else {
            self.tmdbData = try container.decodeIfPresent(TMDBShowData.self, forKey: .tmdbData)
        }
        if let data = try? Data(contentsOf: imagePath) {
            self.thumbnail = UIImage(data: data)
        } else {
            // Image could not be loaded
            self.loadThumbnail()
        }
    }
    
    /// Tries to encode the media object into the given encoder.
    /// - Parameter encoder: The encoder to encode the data into
    /// - Throws: If any of the encoding fails
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        if self.type == .movie {
            if let tmdbData = (self.tmdbData as? TMDBMovieData) {
                try container.encode(tmdbData, forKey: .tmdbData)
            }
        } else {
            if let tmdbData = (self.tmdbData as? TMDBShowData) {
                try container.encode(tmdbData, forKey: .tmdbData)
            }
        }
        try container.encode(self.personalRating, forKey: .personalRating)
        try container.encode(self.tags, forKey: .tags)
        try container.encode(self.watchAgain, forKey: .watchAgain)
        try container.encode(self.notes, forKey: .notes)
        
        // Save the image
        if let data = self.thumbnail?.pngData() {
            let imagePath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(self.id).png")
            do {
                try data.write(to: imagePath)
            } catch let e {
                print(e)
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case tmdbData
        case type
        case personalRating
        case tags
        case watchAgain
        case notes
        case thumbnail
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tmdbData)
        hasher.combine(type)
        hasher.combine(personalRating)
        hasher.combine(tags)
        hasher.combine(watchAgain)
        hasher.combine(notes)
        hasher.combine(thumbnail)
        hasher.combine(year)
        hasher.combine(missingInformation)
    }
    
    // MARK: - Repairable Conformance
    
    /// Attempts to identify problems and repair this media object by reloading the thumbnail, removing corrupted tags and re-loading the cast information
    /// - Parameter progress: A binding for the progress of the repair status
    /// - Returns: The number of fixed and not fixed problems
    func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        // We have to check the following things:
        // tmdbData, thumbnail, tags, missingInformation
        let progressStep = 1.0/4.0
        let group = DispatchGroup()
        var fixed = 0
        let notFixed = 0
        // If we have no TMDBData, we have no tmdbID and therefore no possibility to reload the data.
        guard let tmdbData = self.tmdbData else {
            print("[Verify] Media \(self.id) is missing the tmdbData. Not fixable.")
            progress?.wrappedValue = 1.0
            return .some(fixed: 0, notFixed: 1)
        }
        progress?.wrappedValue += progressStep
        // Thumbnail
        if self.thumbnail == nil && tmdbData.imagePath != nil {
            loadThumbnail()
            fixed += 1
            print("[Verify] '\(tmdbData.title)' (\(id)) is missing the thumbnail. Trying to fix it.")
        }
        progress?.wrappedValue += progressStep
        // Tags
        for tag in tags {
            // If the tag does not exist, remove it
            if !TagLibrary.shared.tags.map(\.id).contains(tag) {
                DispatchQueue.main.async {
                    self.tags.removeFirst(tag)
                    fixed += 1
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) has invalid tags. Removed the invalid tags.")
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

enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case show = "tv"
}
