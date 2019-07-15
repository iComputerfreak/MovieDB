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

class Media: Identifiable, BindableObject, Codable {
    typealias PublisherType = PassthroughSubject<Void, Never>
    var didChange = PublisherType()
    
    enum MediaError: Error {
        case noData
        case encodingFailed(String)
    }
    
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
    var tmdbData: TMDBData? {
        didSet {
            sendChange()
            print("Loading thumbnail for \(self.tmdbData?.title ?? "Unknown")")
            loadThumbnail()
        }
    }
    /// The data from JustWatch.com
    var justWatchData: JustWatchData? {
        didSet {
            sendChange()
        }
    }
    /// The type of media
    var type: MediaType {
        didSet {
            sendChange()
        }
    }
    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: Int {
        didSet {
            sendChange()
        }
    }
    /// A list of user-specified tags
    var tags: [String] {
        didSet {
            sendChange()
        }
    }
    
    private(set) var thumbnail: UIImage? = nil {
        didSet {
            sendChange()
        }
    }
    
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
    
    init(type: MediaType, tmdbData: TMDBData? = nil, justWatchData: JustWatchData? = nil, personalRating: Int = 0, tags: [String] = []) {
        self.id = Self.nextID
        self.tmdbData = tmdbData
        self.justWatchData = justWatchData
        self.type = type
        self.personalRating = personalRating
        self.tags = tags
    }
    
    /// Creates a new Media object from an API Search result and starts the appropriate API calls to fill the data properties
    /// - Parameter searchResult: The result of the API search
    convenience init(from searchResult: TMDBSearchResult) {
        self.init(type: searchResult.mediaType)
        
        // Get the TMDB Data
        let api = TMDBAPI(apiKey: JFLiterals.apiKey)
        api.getMedia(by: searchResult.id, type: searchResult.mediaType) { (data) in
            guard let data = data else {
                print("Error getting TMDB Data for \(searchResult.mediaType.rawValue): \(searchResult.title) [\(searchResult.id)]")
                return
            }
            self.tmdbData = data
        }
        
        // Get the JustWatch Data
        // TODO: Start JustWatch API Call
    }
    
    func sendChange() {
        DispatchQueue.main.async {
            self.didChange.send()
        }
    }
    
    func loadThumbnail() {
        guard let tmdbData = self.tmdbData else {
            return
        }
        guard let imagePath = tmdbData.imagePath, !tmdbData.imagePath!.isEmpty else {
            return
        }
        let urlString = JFUtils.getTMDBImageURL(path: imagePath)
        JFUtils.getRequest(urlString, parameters: [:]) { (data) in
            guard let data = data else {
                print("Unable to get image")
                return
            }
            self.thumbnail = UIImage(data: data)
        }
    }
    
    // MARK: Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(MediaType.self, forKey: .type)
        if type == .movie {
            self.tmdbData = try container.decodeIfPresent(TMDBMovieData.self, forKey: .tmdbData)
            self.justWatchData = try container.decodeIfPresent(JustWatchMovieData.self, forKey: .justWatchData)
        } else {
            self.tmdbData = try container.decodeIfPresent(TMDBShowData.self, forKey: .tmdbData)
            self.justWatchData = try container.decodeIfPresent(JustWatchShowData.self, forKey: .justWatchData)
        }
        self.personalRating = try container.decode(Int.self, forKey: .personalRating)
        self.tags = try container.decode([String].self, forKey: .tags)
        // TODO: Save and load thumbnail to disk separately
        // Save the image
        let imagePath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(self.id).png")
        if let data = try? Data(contentsOf: imagePath) {
            self.thumbnail = UIImage(data: data)
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
            if let justWatchData = (self.justWatchData as? JustWatchMovieData) {
                try container.encode(justWatchData, forKey: .justWatchData)
            }
        } else {
            if let tmdbData = (self.tmdbData as? TMDBShowData) {
                try container.encode(tmdbData, forKey: .tmdbData)
            }
            if let justWatchData = (self.justWatchData as? JustWatchShowData) {
                try container.encode(justWatchData, forKey: .justWatchData)
            }
        }
        try container.encode(self.personalRating, forKey: .personalRating)
        try container.encode(self.tags, forKey: .tags)
        
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case tmdbData
        case justWatchData
        case type
        case personalRating
        case tags
        case thumbnail
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case show = "tv"
}
