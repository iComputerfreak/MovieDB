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
    // TODO: Move ID creation into MediaLibrary? Only save nextID when closing the app, not every time?
    /// Contains the next free collection id
    private static var _nextID = 0
    /// Returns the next free library id
    static var nextID: Int {
        print("Requesting new ID.")
        // Initialize
        if _nextID <= 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextID")
            if _nextID == 0 {
                // No id saved in user defaults. Lets start at 1
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
    
    // MARK: - TMDB Data
    
    // Basic Data
    /// The TMDB ID of the media
    @Published var tmdbID: Int
    /// The name of the media
    @Published var title: String
    /// The original tile of the media
    @Published var originalTitle: String
    /// The path of the media poster image on TMDB
    @Published var imagePath: String?
    /// A list of genres that match the media
    @Published var genres: [Genre]
    /// A short media description
    @Published var overview: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    @Published var status: MediaStatus
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @Published var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @Published var productionCompanies: [ProductionCompany]
    /// The url to the homepage of the media
    @Published var homepageURL: String?
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    @Published var popularity: Float
    /// The average rating on TMDB
    @Published var voteAverage: Float
    /// The number of votes that were cast on TMDB
    @Published var voteCount: Int
    
    /// The list of cast members, that starred in the media
    @Published var cast: [CastMember]
    /// The list of keywords on TheMovieDB.org
    @Published var keywords: [String]
    /// The list of translations available for the media
    @Published var translations: [String]
    /// The list of videos available
    @Published var videos: [Video]
    
    
    // MARK: - Computed Properties
    
    /// Whether the result is a movie and is for adults only
    var isAdultMovie: Bool? { (self as? Movie)?.isAdultMovie }
    
    /// The year of the release or first airing of the media
    var year: Int? {
        var cal = Calendar.current
        cal.timeZone = .utc
        if let releaseDate = (self as? Movie)?.releaseDate {
            return cal.component(.year, from: releaseDate)
        } else if let airDate = (self as? Show)?.firstAirDate {
            return cal.component(.year, from: airDate)
        }
        return nil
    }
    
    // MARK: - Missing Information
    
    /// Represents a user-provided information about a media object.
    /// This enum only contains the information, that will cause the object to show up in the Problems tab, when missing
    enum MediaInformation: String, CaseIterable, Codable {
        case rating
        case watched
        case watchAgain
        case tags
        // Notes are not required for the media object to be complete
        //case notes
    }
    
    /// The set of missing information of this media
    @Published var missingInformation: Set<MediaInformation> = Set(MediaInformation.allCases)
    
    // MARK: - Initializers
    
    /// Creates a new `Media` object.
    /// - Important: Only use this initializer on concrete subclasses of `Media`. Never instantiate `Media` itself.
    init(type: MediaType, tmdbData: TMDBData) {
        // TODO: Add assertion (e.g. type(of: self) == Movie.self or Show.self)
        self.id = Self.nextID
        self.type = type
        // Set all properties from the tmdbData object
        self.tmdbID = tmdbData.id
        self.title = tmdbData.title
        self.originalTitle = tmdbData.originalTitle
        self.imagePath = tmdbData.imagePath
        self.genres = tmdbData.genres
        self.overview = tmdbData.overview
        self.status = tmdbData.status
        self.originalLanguage = tmdbData.originalLanguage
        self.productionCompanies = tmdbData.productionCompanies
        self.homepageURL = tmdbData.homepageURL
        self.popularity = tmdbData.popularity
        self.voteAverage = tmdbData.voteAverage
        self.voteCount = tmdbData.voteCount
        self.cast = tmdbData.cast
        self.keywords = tmdbData.keywords
        self.translations = tmdbData.translations
        self.videos = tmdbData.videos
    }
    
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
    
    // MARK: - Codable Conformance
    // Only used for reading/writing from/to disk.
    // Creating the media objects from API Responses creates and fills the media object manually via the init(tmdbData:) initializer!
    
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
        self.missingInformation = try container.decode(Set<MediaInformation>.self, forKey: .missingInformation)
        
        // TMDB Data
        self.tmdbID = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.originalTitle = try container.decode(String.self, forKey: .originalTitle)
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.status = try container.decode(MediaStatus.self, forKey: .status)
        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        self.productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        self.homepageURL = try container.decode(String?.self, forKey: .homepageURL)
        self.popularity = try container.decode(Float.self, forKey: .popularity)
        self.voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
        self.cast = try container.decode([CastMember].self, forKey: .cast)
        self.keywords = try container.decode([String].self, forKey: .keywords)
        self.translations = try container.decode([String].self, forKey: .translations)
        self.videos = try container.decode([Video].self, forKey: .videos)
        
        // Load the thumbnail
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
        try container.encode(self.personalRating, forKey: .personalRating)
        try container.encode(self.tags, forKey: .tags)
        try container.encode(self.watchAgain, forKey: .watchAgain)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.missingInformation, forKey: .missingInformation)
        
        // TMDB Data
        try container.encode(tmdbID, forKey: .tmdbID)
        try container.encode(title, forKey: .title)
        try container.encode(originalTitle, forKey: .originalTitle)
        try container.encode(imagePath, forKey: .imagePath)
        try container.encode(genres, forKey: .genres)
        try container.encode(overview, forKey: .overview)
        try container.encode(status, forKey: .status)
        try container.encode(originalLanguage, forKey: .originalLanguage)
        try container.encode(productionCompanies, forKey: .productionCompanies)
        try container.encode(homepageURL, forKey: .homepageURL)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
        try container.encode(self.cast, forKey: .cast)
        try container.encode(self.keywords, forKey: .keywords)
        try container.encode(self.translations, forKey: .translations)
        try container.encode(self.videos, forKey: .videos)
        
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
        case missingInformation
        
        // TMDB Data
        case tmdbID
        case title
        case originalTitle
        case imagePath
        case genres
        case overview
        case status
        case originalLanguage
        case productionCompanies
        case homepageURL
        case popularity
        case voteAverage
        case voteCount
        case cast
        case keywords
        case translations
        case videos
    }
    
    // MARK: - Hashable Conformance
    
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(personalRating)
        hasher.combine(tags)
        hasher.combine(watchAgain)
        hasher.combine(notes)
        hasher.combine(thumbnail)
        hasher.combine(year)
        hasher.combine(missingInformation)
        
        // TMDB Data
        hasher.combine(tmdbID)
        hasher.combine(title)
        hasher.combine(originalTitle)
        hasher.combine(imagePath)
        hasher.combine(genres)
        hasher.combine(overview)
        hasher.combine(status)
        hasher.combine(originalLanguage)
        hasher.combine(productionCompanies)
        hasher.combine(homepageURL)
        hasher.combine(popularity)
        hasher.combine(voteAverage)
        hasher.combine(voteCount)
        hasher.combine(cast)
        hasher.combine(keywords)
        hasher.combine(translations)
        hasher.combine(videos)
    }
}

enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case show = "tv"
}
