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

class Media: Identifiable, ObservableObject, Codable {
    
    enum MediaError: Error {
        case noData
        case encodingFailed(String)
    }
    
    // MARK: - Properties
    // Media ID Creation
    /// Contains the next free collection id
    private static var _nextID = -1
    /// Returns the next free library id
    static var nextID: Int {
        // Initialize
        if _nextID < 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextID")
        }
        // Increase _nextID after returning
        defer {
            _nextID += 1
            UserDefaults.standard.set(_nextID, forKey: "nextID")
        }
        return _nextID
    }
    
    /// The internal library id
    let id: Int
    /// The data from TMDB
    @Published var tmdbData: TMDBData? = nil
    /// The type of media
    @Published var type: MediaType
    /// A rating between 0 and 10 (no Rating and 5 stars)
    @Published var personalRating: Int = 0
    /// A list of user-specified tags, listed by their id
    @Published var tags: [Int] = []
    /// Whether the user would watch the media again
    @Published var watchAgain: Bool? = nil
    /// Personal notes on the media
    @Published var notes: String = ""
    
    @Published var thumbnail: UIImage? = nil
    
    // MARK: Loaded from Wrappers
    /// The list of cast members, that starred in the media
    @Published var cast: [CastMember] = []
    /// The list of keywords on TheMovieDB.org
    @Published var keywords: [String] = []
    /// The list of translations available for the media
    @Published var translations: [String] = []
    /// The list of videos available
    @Published var videos: [Video] = []
    
    /// Whether the result is a movie and is for adults only
    var isAdult: Bool? { (tmdbData as? TMDBMovieData)?.isAdult }
    
    /// The year of the release or first airing of the media
    var year: Int? {
        let cal = Calendar.current
        if let movieData = tmdbData as? TMDBMovieData, let releaseDate = movieData.releaseDate {
            return cal.component(.year, from: releaseDate)
        } else if let showData = tmdbData as? TMDBShowData, let airDate = showData.firstAirDate {
            return cal.component(.year, from: airDate)
        }
        return nil
    }
    
    // Only used by constructing subclasses
    
    /// Creates a new `Media` object.
    /// - Important: Only use this initializer on concrete subclasses of `Media`. Never instantiate `Media` itself.
    init(type: MediaType) {
        self.id = Self.nextID
        self.type = type
    }
    
    /// Creates a new Media object from an API Search result and starts the appropriate API calls to fill the data properties
    /// - Parameter searchResult: The result of the API search
    /// - Returns: A concrete subclass of `Media` created from the given search result data
    static func create(from searchResult: TMDBSearchResult) -> Media {
        // Create either a movie or a show and return it. Don't instantiate Media directly
        let media: Media!
        if searchResult.mediaType == .movie {
            media = Movie()
        } else {
            media = Show()
        }
        
        // Get the TMDB Data from the API
        let api = TMDBAPI(apiKey: JFLiterals.apiKey)
        api.getMedia(by: searchResult.id, type: searchResult.mediaType) { (data) in
            guard let data = data else {
                print("Error getting TMDB Data for \(searchResult.mediaType.rawValue): \(searchResult.title) [\(searchResult.id)]")
                return
            }
            // Completion closure may be in other thread
            DispatchQueue.main.async {
                media.tmdbData = data
                media.loadThumbnail()
            }
        }
                
        api.getCast(by: searchResult.id, type: searchResult.mediaType) { wrapper in
            print("[\(searchResult.title)] Loaded \(wrapper?.cast.count ?? -1) Cast Members")
            if let cast = wrapper?.cast {
                DispatchQueue.main.async {
                    media.cast = cast
                }
            }
        }
        
        api.getKeywords(by: searchResult.id, type: searchResult.mediaType) { wrapper in
            print("[\(searchResult.title)] Loaded \(wrapper?.keywords.count ?? -1) Keywords")
            if let keywords = wrapper?.keywords {
                DispatchQueue.main.async {
                    // Save only the keyword names, ignore the id
                    media.keywords = keywords.map({ $0.name })
                }
            }
        }
        
        api.getVideos(by: searchResult.id, type: searchResult.mediaType) { wrapper in
            print("[\(searchResult.title)] Loaded \(wrapper?.videos.count ?? -1) Videos")
            if let videos = wrapper?.videos {
                DispatchQueue.main.async {
                    // Save only the trailers
                    media.videos = videos.filter({ $0.type == .trailer })
                }
            }
        }
        
        api.getTranslations(by: searchResult.id, type: searchResult.mediaType) { wrapper in
            print("[\(searchResult.title)] Loaded \(wrapper?.translations.count ?? -1) Translations")
            if let translations = wrapper?.translations {
                DispatchQueue.main.async {
                    // Save only the localized names, not the english names
                    media.translations = translations.map({ $0.name })
                }
            }
        }
        
        return media
    }
    
    // Only gets triggered in the custom init, so only when creating the object with `Media.create(from:)`
    func loadThumbnail() {
        guard let tmdbData = self.tmdbData else {
            // Function invoked, without tmdbData being initialized
            return
        }
        guard thumbnail == nil else {
            // Thumbnail already present, don't download again
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(MediaType.self, forKey: .type)
        self.personalRating = try container.decode(Int.self, forKey: .personalRating)
        self.tags = try container.decode([Int].self, forKey: .tags)
        self.watchAgain = try container.decode(Bool?.self, forKey: .watchAgain)
        self.notes = try container.decode(String.self, forKey: .notes)
        let imagePath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(self.id).png")
        if let data = try? Data(contentsOf: imagePath) {
            self.thumbnail = UIImage(data: data)
        }
        if type == .movie {
            self.tmdbData = try container.decodeIfPresent(TMDBMovieData.self, forKey: .tmdbData)
        } else {
            self.tmdbData = try container.decodeIfPresent(TMDBShowData.self, forKey: .tmdbData)
        }
    }
    
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
        case cast
        case keywords
        case translations
        case videos
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case show = "tv"
}
