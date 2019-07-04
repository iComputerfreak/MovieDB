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

class Media: Identifiable, BindableObject {
    typealias PublisherType = PassthroughSubject<Void, Never>
    var didChange = PublisherType()
    
    enum InitializationError: Error {
        case noData
    }
    
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
                print("Error getting TMDB Data for id \(searchResult.title)")
                return
            }
            self.tmdbData = data
        }
        
        // Get the JustWatch Data
        // TODO: Start JustWatch API Call
    }
    
    func sendChange() {
        DispatchQueue.main.sync {
            didChange.send()
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
}

enum MediaType: String, Codable {
    case movie = "movie"
    case show = "tv"
}
