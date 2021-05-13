//
//  CSVManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CSVImporter
import CoreData

struct CSVManager {
    
    static let separator: Character = ";"
    static let arraySeparator: Character = ","
    static let lineSeparator: Character = "\n"
    /// The `DateFormatter` used for de- and encoding dates
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    typealias Converter = (Any) -> String
    
    enum CSVKey: String, CaseIterable {
        // Import
        case tmdbID = "tmdb_id"
        case mediaType = "type"
        case personalRating = "personal_rating"
        case watchAgain = "watch_again"
        case tags
        case notes
        // Movie exclusive
        case watched
        // Show exclusive
        case lastWatched = "last_episode_watched"
        
        // Export only
        case id
        case originalTitle = "original_title"
        case genres
        case overview
        case status
        case releaseDate = "release_date"
        case runtime
        case budget
        case revenue
        case isAdult = "is_adult"
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case isInProduction = "is_in_production"
        case showType = "show_type"
        
        case creationDate = "creation_date"
    }
    
    enum CSVError: Error {
        case noTMDBID
        case noMediaType
        case mediaAlreadyExists
    }
    
    static let requiredImportKeys: [CSVKey] = [.tmdbID, .mediaType]
    static let optionalImportKeys: [CSVKey] = [.personalRating, .watchAgain, .tags, .notes, .watched, .lastWatched, .creationDate]
    static let exportKeys: [CSVKey] = CSVKey.allCases
    
    // MARK: Export KeyPaths
    /// Contains the corresponding key paths for all Media `CSVKey`s and an optional converter closure to convert the value to String
    static let exportKeyPaths: [CSVKey: (PartialKeyPath<Media>, Converter?)] = [
        .tmdbID: (\Media.tmdbID, nil),
        .mediaType: (\Media.type, { ($0 as! MediaType).rawValue }),
        .personalRating: (\Media.personalRating, { String(($0 as! StarRating).integerRepresentation) }),
        .watchAgain: (\Media.watchAgain, nil),
        .tags: (\Media.tags, { ($0 as! Set<Tag>).map(\.name).sorted().joined(separator: String(arraySeparator)) }),
        .notes: (\Media.notes, nil),
        .creationDate: (\Media.creationDate, { dateFormatter.string(from: $0 as! Date) }),
        
        .id: (\Media.id as KeyPath<Media, UUID>, { ($0 as! UUID).uuidString }),
        .originalTitle: (\Media.originalTitle, nil),
        .genres: (\Media.genres, { ($0 as! Set<Genre>).map(\.name).sorted().joined(separator: String(arraySeparator)) }),
        .overview: (\Media.overview, nil),
        .status: (\Media.status, { ($0 as! MediaStatus).rawValue })
    ]
    static let movieExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Movie>, Converter?)] = [
        .watched: (\Movie.watched, nil),
        
        .releaseDate: (\Movie.releaseDate, { dateFormatter.string(from: $0 as! Date) }),
        .runtime: (\Movie.runtime, nil),
        .revenue: (\Movie.revenue, nil),
        .budget: (\Movie.budget, nil),
        .isAdult: (\Movie.isAdult, nil)
    ]
    static let showExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Show>, Converter?)] = [
        .lastWatched: (\Show.lastWatched, nil),
        
        .firstAirDate: (\Show.firstAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .lastAirDate: (\Show.lastAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .numberOfSeasons: (\Show.numberOfSeasons, nil),
        .isInProduction: (\Show.isInProduction, nil),
        .showType: (\Show.showType, { ($0 as! ShowType).rawValue })
    ]
    
    static func createMedia(from values: [String: String], context: NSManagedObjectContext) throws -> Media? {
        // We only need the tmdbID and user values from the CSV
        guard let tmdbIDValue = values[.tmdbID], let tmdbID = Int(tmdbIDValue) else {
            throw CSVError.noTMDBID
        }
        guard let mediaTypeValue = values[.mediaType], let mediaType = MediaType(rawValue: mediaTypeValue) else {
            throw CSVError.noMediaType
        }
        
        // Check if media with this tmdbID already exists
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", "tmdbID", String(tmdbID))
        fetchRequest.fetchLimit = 1
        let existingAmount = (try? context.count(for: fetchRequest)) ?? 0
        if existingAmount > 0 {
            // Media already exists in context
            throw CSVError.mediaAlreadyExists
        }
        
        // Create the media
        let media = try TMDBAPI.shared.fetchMedia(id: tmdbID, type: mediaType, context: context)
        
        // Setting values with PartialKeyPaths is not possible, so we have to do it manually
        // Specifying ReferenceWritableKeyPaths in the dictionary with the converters is not possible, since the dictionary Value type would not be identical then
        if let rawRating = values[.personalRating], let intRep = Int(rawRating), let personalRating = StarRating(integerRepresentation: intRep) {
            media.personalRating = personalRating
        }
        if let rawWatchAgain = values[.watchAgain], let watchAgain = Bool(rawWatchAgain) {
            media.watchAgain = watchAgain
        }
        if let rawTags = values[.tags] {
            var tags: [Tag] = []
            let tagNames = rawTags.split(separator: arraySeparator).map(String.init)
            if !tagNames.isEmpty {
                for name in tagNames {
                    // Create the tag if it does not exist yet
                    let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "%K = %@", "name", name)
                    fetchRequest.fetchLimit = 1
                    if let tag = try? context.fetch(fetchRequest).first {
                        assert(tag.managedObjectContext == context)
                        tags.append(tag)
                    } else {
                        // Create a new tag with the name
                        let tag = Tag(name: name, context: context)
                        tags.append(tag)
                    }
                }
                media.tags = Set(tags)
            }
        }
        if let notes = values[.notes] {
            media.notes = notes
        }
        if let rawWatched = values[.watched], let watched = Bool(rawWatched) {
            if mediaType == .movie {
                (media as! Movie).watched = watched
            }
        }
        if let rawLastWatched = values[.lastWatched], let lastWatched = EpisodeNumber(rawLastWatched) {
            if mediaType == .show {
                (media as! Show).lastWatched = lastWatched
            }
        }
        if let rawCreationDate = values[.creationDate], let creationDate = dateFormatter.date(from: rawCreationDate) {
            media.creationDate = creationDate
        }
        
        media.loadThumbnailAsync()
        
        return media
    }
    
    /// Creates a CSV record (line) from the given media object
    /// - Parameter media: The media object to export
    /// - Returns: The CSV line as a dictionary with all string values, keyed by their CSV header
    static func createRecord(from media: Media) -> [CSVKey: String] {
        var values: [CSVKey: String] = [:]
        for key in self.exportKeys {
            var tuple: (Any, Converter?)? = nil
            
            // Extract the value by reading the KeyPath; Pass the converter to the tuple
            if let (keyPath, conv) = self.exportKeyPaths[key] {
                let value = media[keyPath: keyPath]
                tuple = (value, conv)
            } else if let (keyPath, conv) = self.movieExclusiveExportKeyPaths[key] {
                if let movie = media as? Movie {
                    let value = movie[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Movie, we leave the value blank
                    tuple = ("", nil)
                }
            } else if let (keyPath, conv) = self.showExclusiveExportKeyPaths[key] {
                if let show = media as? Show {
                    let value = show[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Show, we leave the value blank
                    tuple = ("", nil)
                }
            } else {
                fatalError("The key \(key) has no assigned KeyPath. Please add the key to one of the following dictionaries: keyPaths, movieExclusiveKeyPaths or showExclusiveKeyPaths.")
            }
            
            // Unwrap the value and converter
            var (value, converter) = tuple!
            
            // Convert the value, if a converter was given
            if converter != nil {
                value = converter!(value)
            }
            
            // Convert the value to a string (and convert nil to "")
            var stringValue: String
            switch value {
                case Optional<Any>.none:
                    stringValue = ""
                default:
                    // Create a mirror of the object to read the `some` property of the Optional
                    let mirror = Mirror(reflecting: value)
                    // If value is an Optional
                    if mirror.displayStyle == .optional {
                        // Since `value` is an Optional, it has exactly one property (`some`)
                        let unwrapped = mirror.children.first?.value
                        stringValue = "\(unwrapped ?? "")"
                    } else {
                        // If value is no Optional, we don't need to unwrap it
                        stringValue = "\(value)"
                    }
            }
            
            // Double all quotation marks in the value (escape them)
            stringValue = stringValue.replacingOccurrences(of: "\"", with: "\"\"")
            
            // If the value contains a separator, encapsulate the value in quotation marks
            if stringValue.contains(separator) {
                stringValue = "\"\(stringValue)\""
            }
            
            // Save the value to the values dict
            values[key] = stringValue
        }
        
        return values
    }
    
    /// Creates a CSV string representing the given list of media objects
    /// - Parameter mediaObjects: The list of media objects to encode
    /// - Returns: The CSV string
    static func createCSV(from mediaObjects: [Media]) -> String {
        var csv: [String] = []
        // CSV Header
        csv.append(exportKeys.map(\.rawValue).joined(separator: String(separator)))
        // CSV Values
        for mediaObject in mediaObjects {
            let values = self.createRecord(from: mediaObject)
            let line: [String] = exportKeys.map({ values[$0]! })
            csv.append(line.joined(separator: String(separator)))
        }
        return csv.joined(separator: String(lineSeparator))
    }
    
}

fileprivate extension Dictionary where Key == String {
    
    subscript(key: CSVManager.CSVKey) -> Value? {
        get {
            return self[key.rawValue]
        }
        set(newValue) {
            self[key.rawValue] = newValue
        }
    }
    
}
