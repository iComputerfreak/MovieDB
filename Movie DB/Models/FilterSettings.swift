//
//  FilterSettings.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class FilterSettings: ObservableObject, Codable {
        
    static private let key = "filterSettings"
    static let shared = FilterSettings.load()
        
    // MARK: Smart Filters
    
    // MARK: Basic Filters
    @Published var isAdult: Bool? = nil
    @Published var mediaType: MediaType? = nil
    @Published var genres: [Genre] = []
    // var parentalRating
    @Published var rating: ClosedRange<StarRating>? = nil
    @Published var year: ClosedRange<Int>? = nil
    @Published var status: [MediaStatus] = []
    // Show Specific
    @Published var showTypes: [ShowType] = []
    @Published var numberOfSeasons: ClosedRange<Int>? = nil
        
    // MARK: User Data
    @Published var watched: Bool? = nil
    @Published var watchAgain: Bool? = nil
    @Published var tags: [Int] = []
    
    private init() {}
    
    /// Loads the filter settings from disk
    /// - Returns: The loaded filter settings
    static func load() -> FilterSettings {
        // Load the settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let settings = try PropertyListDecoder().decode(FilterSettings.self, from: data)
                return settings
            } catch let error {
                print("Error decoding filter settings: \(error)")
            }
        }
        return FilterSettings()
    }
    
    /// Saves the filter settings to disk
    static func save() {
        do {
            let data = try PropertyListEncoder().encode(shared)
            UserDefaults.standard.set(data, forKey: key)
        } catch let error {
            print("Error encoding filter settings: \(error)")
        }
    }
    
    /// Returns the media objects matching the current filter
    /// - Parameter mediaList: The media objects to filter
    /// - Returns: The filtered media objects
    func applied(on mediaList: [Media]) -> [Media] {
        return mediaList.filter(matches(_:))
    }
    
    /// Returns, whether the given media object matches the filter
    /// - Parameter media: The media object to match
    /// - Returns: Whether the given media object matches the current filter
    func matches(_ media: Media) -> Bool {
        // MARK: Is Adult
        if let isAdult = isAdult {
            // If isAdult is not set on the media, ignore this filter!
            if media.isAdultMovie != nil && media.isAdultMovie != isAdult {
                return false
            }
        }
        // MARK: Media Type
        if let type = mediaType {
            if media.type != type {
                return false
            }
        }
        // MARK: Genres
        if !genres.isEmpty {
            if !matchesArray(filterArray: self.genres, actualArray: Array(media.genres)) {
                return false
            }
        }
        // MARK: Rating
        if let rating = rating {
            if !(rating ~= media.personalRating) {
                return false
            }
        }
        // MARK: Year
        if let year = year, let mediaYear = media.year {
            if !(year ~= mediaYear) {
                return false
            }
        }
        // MARK: Status
        if !status.isEmpty {
            if !status.contains(media.status) {
                return false
            }
        }
        // MARK: Show Type
        if !showTypes.isEmpty, let mediaShowType = (media as? Show)?.showType {
            if !showTypes.contains(mediaShowType) {
                return false
            }
        }
        // MARK: Number of Seasons
        if let numberOfSeasons = numberOfSeasons, let mediaSeasons = (media as? Show)?.numberOfSeasons {
            if !(numberOfSeasons ~= mediaSeasons) {
                return false
            }
        }
        // MARK: Watched
        if let watched = watched {
            // Either movie
            if let movie = media as? Movie {
                if movie.watched != nil && movie.watched! != watched {
                    return false
                }
            } else if let show = media as? Show {
                let showWatched = show.lastEpisodeWatched != nil
                if showWatched != watched {
                    return false
                }
            }
        }
        // MARK: Watch again
        if let watchAgain = watchAgain, let mediaWatchAgain = media.watchAgain {
            if watchAgain != mediaWatchAgain {
                return false
            }
        }
        // MARK: Tags
        if !tags.isEmpty {
            if !matchesArray(filterArray: tags, actualArray: media.tags) {
                return false
            }
        }
        
        // No filter contradicted the media properties
        return true
    }
    
    private func matchesArray<T: Equatable>(filterArray: [T], actualArray: [T]?) -> Bool {
        precondition(!filterArray.isEmpty, "Please make sure that the filter array is not empty before calling this function.")
        guard let actualArray = actualArray, !actualArray.isEmpty else {
            // Include items that have no data
            return true
        }
        for item in actualArray {
            if filterArray.contains(item) {
                // Only one of the genres has to be in the filter array
                return true
            }
        }
        return false
    }
    
    func reset() {
        self.isAdult = nil
        self.mediaType = nil
        self.genres = []
        self.rating = nil
        self.year = nil
        self.status = []
        self.showTypes = []
        self.numberOfSeasons = nil
        self.watched = nil
        self.watchAgain = nil
        self.tags = []
    }
    
    /// Creates two proxies for the upper and lower bound of the given range Binding
    ///
    /// Ensures that the set values never exceed the given bounds and that the set values form a valid range (`lowerBound <= upperBound`)
    ///
    /// - Parameters:
    ///   - setting: The binding for the `ClosedRange` to create proxies from
    ///   - bounds: The bounds of the range
    static func rangeProxies<T>(for setting: Binding<ClosedRange<T>?>, bounds: ClosedRange<T>) -> (lower: Binding<T>, upper: Binding<T>) {
        var lowerProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.lowerBound ?? bounds.lowerBound }, set: { lower in
                // Ensure that we are not setting an illegal range
                var lower = max(lower, bounds.lowerBound)
                let upper = setting.wrappedValue?.upperBound ?? bounds.upperBound
                if lower > upper {
                    // Illegal range selected, set lower to lowest value possible
                    lower = upper
                }
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
            })
        }
        
        var upperProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.upperBound ?? bounds.upperBound }, set: { upper in
                let lower = setting.wrappedValue?.lowerBound ?? bounds.lowerBound
                var upper = min(upper, bounds.upperBound)
                if lower > upper {
                    // Illegal range selected
                    upper = lower
                }
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
            })
        }
        
        return (lowerProxy, upperProxy)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isAdult = try container.decode(Bool?.self, forKey: .isAdult)
        self.mediaType = try container.decode(MediaType?.self, forKey: .mediaType)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.rating = try container.decode(ClosedRange<StarRating>?.self, forKey: .rating)
        self.year = try container.decode(ClosedRange<Int>?.self, forKey: .year)
        self.status = try container.decode([MediaStatus].self, forKey: .status)
        self.showTypes = try container.decode([ShowType].self, forKey: .showTypes)
        self.numberOfSeasons = try container.decode(ClosedRange<Int>?.self, forKey: .numberOfSeasons)
        self.watched = try container.decode(Bool?.self, forKey: .watched)
        self.watchAgain = try container.decode(Bool?.self, forKey: .watchAgain)
        self.tags = try container.decode([Int].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isAdult, forKey: .isAdult)
        try container.encode(self.mediaType, forKey: .mediaType)
        try container.encode(self.genres, forKey: .genres)
        try container.encode(self.rating, forKey: .rating)
        try container.encode(self.year, forKey: .year)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.showTypes, forKey: .showTypes)
        try container.encode(self.numberOfSeasons, forKey: .numberOfSeasons)
        try container.encode(self.watched, forKey: .watched)
        try container.encode(self.watchAgain, forKey: .watchAgain)
        try container.encode(self.tags, forKey: .tags)
    }
    
    enum CodingKeys: String, CodingKey {
        case isAdult
        case mediaType
        case genres
        case rating
        case year
        case status
        case showTypes
        case numberOfSeasons
        case watched
        case watchAgain
        case tags
    }
    
}
