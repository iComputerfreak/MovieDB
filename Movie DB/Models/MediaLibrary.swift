//
//  MediaLibrary.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// Represents a wrapper for the Media array conforming to `ObservableObject` and adding a few convenience functions
class MediaLibrary: ObservableObject, Codable {
    
    /// The shared `MediaLibrary` instance.
    static let shared: MediaLibrary = MediaLibrary.load()
    
    var lastUpdate: Date?
    @Published private(set) var mediaList: [Media]
    
    private init() {
        self.mediaList = []
        self.lastUpdate = nil
        // Set up the notifications to save when the app enters background
        NotificationCenter.default.addObserver(self, selector: #selector(willResign(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func willResign(notification: Notification) {
        save()
    }
    
    /// Loads the media library from the user defaults, or returns a new one, if none was saved.
    static func load() -> MediaLibrary {
        // Load the media library from UserDefaults
        if let data = UserDefaults.standard.data(forKey: JFLiterals.Keys.mediaLibrary) {
            do {
                return try PropertyListDecoder().decode(MediaLibrary.self, from: data)
            } catch let e {
                print("Error loading media library. Malformed data.")
                print(e)
            }
        }
        return MediaLibrary()
    }
    
    /// Saves this media library to the user defaults
    func save(_ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        DispatchQueue.global().async {
            // Encode the array into a property list
            let pList = try? PropertyListEncoder().encode(self)
            UserDefaults.standard.set(pList, forKey: JFLiterals.Keys.mediaLibrary)
            // Output "[Class.function:line] Library saved"
            print("[\(file.components(separatedBy: "/").last!.removingSuffix(".swift")).\(function):\(line)] Library saved")
        }
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() -> (successes: Int, failures: Int) {
        var successes: Int = 0
        var failures: Int = 0
        let api = TMDBAPI.shared
        api.getChanges(from: lastUpdate, to: Date()) { (changes) in
            // Iterate over the library, not the changed IDs for performance reasons
            for media in self.mediaList {
                if changes.contains(media.tmdbData?.id ?? -1) {
                    // This media has been changed
                    // TODO: Throttle API Calls
                    if api.updateMedia(media) {
                        successes += 1
                    } else {
                        failures += 1
                    }
                }
            }
            self.lastUpdate = Date()
        }
        return (successes, failures)
    }
    
    func append(_ object: Media) {
        self.mediaList.append(object)
        save()
    }
    
    func append(contentsOf objects: [Media]) {
        self.mediaList.append(contentsOf: objects)
        save()
    }
    
    // Removes and saves the library
    func remove(id: Int) {
        let index = self.mediaList.firstIndex(where: { $0.id == id })
        guard index != nil else {
            return
        }
        let id = mediaList[index!].id
        self.mediaList.remove(at: index!)
        let thumbnailPath = JFUtils.url(for: "thumbnails").appendingPathComponent("\(id).png")
        // Try to delete the thumbnail from disk
        self.save()
        DispatchQueue.global().async {
            try? FileManager.default.removeItem(at: thumbnailPath)
        }
    }
    
    func reset() {
        self.mediaList.removeAll()
        // Delete all thumbnails
        try? FileManager.default.removeItem(at: JFUtils.url(for: "thumbnails"))
        try? FileManager.default.createDirectory(at: JFUtils.url(for: "thumbnails"), withIntermediateDirectories: true)
        // Reset the ID counter for the media objects
        Media.resetNextID()
        save()
    }
    
    // MARK: - Problems
    func problems() -> [Media: Set<Media.MediaInformation>] {
        var problems: [Media: Set<Media.MediaInformation>] = [:]
        for media in mediaList {
            if !media.missingInformation.isEmpty {
                problems[media] = media.missingInformation
            }
        }
        return problems
    }
    
    func duplicates() -> [Int?: [Media]] {
        // Group the media objects by their TMDB IDs
        return Dictionary(grouping: self.mediaList, by: \.tmdbData?.id)
            // Filter out all IDs with only one media object
            .filter { (key: Int?, value: [Media]) in
                return value.count > 1
            }
    }
    
    
    // MARK: - Codable Conformance
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        // Contains the page and results
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Contains the TMDBSearchResults array
        // Create two identical containers, so we can extract the same value twice
        var mediaObjects = try container.nestedUnkeyedContainer(forKey: .mediaList)
        var mediaObjects2 = try container.nestedUnkeyedContainer(forKey: .mediaList)
        assert(mediaObjects.count == mediaObjects2.count)
        while (!mediaObjects.isAtEnd) {
            // Get the Movie or Show as a GenericMedia object
            let movieOrShowContainer = try mediaObjects.nestedContainer(keyedBy: GenericMedia.CodingKeys.self)
            // Read the type of the Media container
            let mediaType = try movieOrShowContainer.decode(MediaType.self, forKey: .type)
            // Decide based on the media type which type to use for decoding
            switch mediaType {
                case .movie:
                    self.mediaList.append(try mediaObjects2.decode(Movie.self))
                case .show:
                    self.mediaList.append(try mediaObjects2.decode(Show.self))
            }
        }
        print("Loaded \(self.mediaList.count) Media objects.")
        // Load other properties
        self.lastUpdate = try container.decode(Date?.self, forKey: .lastUpdate)
    }
    
    private struct Empty: Decodable {}
    
    private struct GenericMedia: Codable {
        var type: MediaType
        enum CodingKeys: String, CodingKey {
            case type
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // Encode all Media Objects
        var container = encoder.container(keyedBy: CodingKeys.self)
        var arrayContainer = container.nestedUnkeyedContainer(forKey: .mediaList)
        for media in mediaList {
            if media.type == .movie {
                try arrayContainer.encode(media as! Movie)
            } else {
                try arrayContainer.encode(media as! Show)
            }
        }
        // Encode other properties
        try container.encode(self.lastUpdate, forKey: .lastUpdate)
    }
    
    enum CodingKeys: CodingKey {
        case mediaList
        
        case lastUpdate
    }
    
}
