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
        print("Requesting new ID.")
        // Initialize
        if _nextID < 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextID")
        }
        // Increase _nextID after returning
        defer {
            _nextID += 1
            UserDefaults.standard.set(_nextID, forKey: "nextID")
        }
        print("Returning new ID \(_nextID)")
        return _nextID
    }
    
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
    @Published var personalRating: StarRating = .noRating
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
    
    enum RepairProblem {
        case noProblems
        case fixed
        case notFixed
    }
    
    func repair() -> [RepairProblem] {
        let group = DispatchGroup()
        var problems: [RepairProblem] = []
        // If we have no TMDBData, we have no tmdbID and therefore no possibility to reload the data.
        guard let tmdbData = self.tmdbData else {
            print("[Verify] Media \(self.id) is missing the tmdbData. Not fixable.")
            return [.notFixed]
        }
        // Thumbnail
        if self.thumbnail == nil && tmdbData.imagePath != nil {
            loadThumbnail()
            problems.append(.fixed)
            print("[Verify] '\(tmdbData.title)' (\(id)) is missing the thumbnail. Trying to fix it.")
        }
        // Tags
        for tag in tags {
            // If the tag does not exist, remove it
            if !TagLibrary.shared.tags.map(\.id).contains(tag) {
                DispatchQueue.main.async {
                    self.tags.removeFirst(tag)
                    problems.append(.fixed)
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) has invalid tags. Removed the invalid tags.")
                }
            }
        }
        // Cast
        if cast.isEmpty {
            group.enter()
            TMDBAPI.shared.getCast(by: tmdbData.id, type: type) { (wrapper) in
                if let wrapper = wrapper {
                    DispatchQueue.main.async {
                        // If the cast is empty, there was no problem in the first place
                        guard !wrapper.cast.isEmpty else {
                            return
                        }
                        self.cast = wrapper.cast
                        problems.append(.fixed)
                        print("[Verify] '\(tmdbData.title)' (\(self.id)) is missing the cast. Cast re-downloaded.")
                    }
                } else {
                    problems.append(.notFixed)
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) is missing the cast. Cast could not be re-downloaded.")
                }
                group.leave()
            }
        }
        group.wait()
        return problems.isEmpty ? [.noProblems] : problems
    }
    
    // MARK: - Codable Conformance
    
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
        self.cast = try container.decode([CastMember].self, forKey: .cast)
        self.keywords = try container.decode([String].self, forKey: .keywords)
        self.translations = try container.decode([String].self, forKey: .translations)
        self.videos = try container.decode([Video].self, forKey: .videos)
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
        
        try container.encode(self.cast, forKey: .cast)
        try container.encode(self.keywords, forKey: .keywords)
        try container.encode(self.translations, forKey: .translations)
        try container.encode(self.videos, forKey: .videos)
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

enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case show = "tv"
}
