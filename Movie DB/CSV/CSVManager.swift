//
//  CSVManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import CSVImporter
import Foundation
import RegexBuilder

// swiftlint:disable type_body_length
/// Represents a static helper class to import and export media objects to and from CSV
struct CSVManager {
    typealias Converter = (Any) -> String
    
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

    /// The `ISO8601DateFormatter` used for de- and encoding date-times
    static let dateTimeFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.timeZone = .utc
        return f
    }()
    
    /// The CSV keys that are required to be present when importing media
    static let requiredImportKeys: [CSVKey] = [.tmdbID, .mediaType]
    /// The CSV keys that are optional when importing media
    static let optionalImportKeys: [CSVKey] = [
        .personalRating, .watchAgain, .tags, .notes, .movieWatched, .lastSeasonWatched, .lastEpisodeWatched,
        .creationDate, .modificationDate,
    ]
    // swiftlint:enable multiline_literal_brackets
    /// The properties/CSV keys that will be included in the export CSV data (do not include the legacy `showWatched` key)
    static let exportKeys: [CSVKey] = CSVKey.allCases.filter { $0 != .showWatched }
    
    // MARK: Export KeyPaths
    // swiftlint:disable force_cast
    /// Contains the corresponding key paths for all Media `CSVKey`s and an optional converter closure to convert the value to String
    static let exportKeyPaths: [CSVKey: (PartialKeyPath<Media>, Converter?)] = [
        .tmdbID: (\Media.tmdbID, nil),
        .mediaType: (\Media.type, { ($0 as! MediaType).rawValue }),
        .personalRating: (\Media.personalRating, { String(($0 as! StarRating).integerRepresentation) }),
        .watchAgain: (\Media.watchAgain, nil),
        .tags: (\Media.tags, { ($0 as! Set<Tag>).map(\.name).sorted().joined(separator: arraySeparator) }),
        .notes: (\Media.notes, nil),
        .creationDate: (\Media.creationDate, { dateTimeFormatter.string(from: $0 as! Date) }),
        .modificationDate: (\Media.modificationDate, { dateTimeFormatter.string(from: $0 as! Date) }),
        
        .id: (\Media.id as KeyPath<Media, UUID?>, { ($0 as! UUID).uuidString }),
        .title: (\Media.title, nil),
        .originalTitle: (\Media.originalTitle, nil),
        .genres: (\Media.genres, { ($0 as! Set<Genre>).map(\.name).sorted().joined(separator: arraySeparator) }),
        .overview: (\Media.overview, nil),
        .status: (\Media.status, { ($0 as! MediaStatus).rawValue }),
        .tagline: (\Media.tagline, nil),
    ]
    static let movieExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Movie>, Converter?)] = [
        .movieWatched: (\Movie.watched, { ($0 as! MovieWatchState).rawValue }),
        
        .releaseDate: (\Movie.releaseDate, { dateFormatter.string(from: $0 as! Date) }),
        .runtime: (\Movie.runtime, nil),
        .revenue: (\Movie.revenue, nil),
        .budget: (\Movie.budget, nil),
        .isAdult: (\Movie.isAdult, nil),
    ]
    static let showExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Show>, Converter?)] = [
        .lastSeasonWatched: (\Show.watched, { ($0 as! ShowWatchState).season.description }),
        .lastEpisodeWatched: (\Show.watched, { ($0 as! ShowWatchState).episode?.description ?? "" }),
        
        .firstAirDate: (\Show.firstAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .lastAirDate: (\Show.lastAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .numberOfSeasons: (\Show.numberOfSeasons, nil),
        .isInProduction: (\Show.isInProduction, nil),
        .showType: (\Show.showType, { ($0 as! ShowType).rawValue }),
        .createdBy: (\Show.createdBy, { ($0 as! [String]).sorted().joined(separator: arraySeparator) }),
    ]
    // swiftlint:enable force_cast
    
    // This is a static helper class. We do not need to make instances of it.
    private init() {}
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    /// Creates a ``Media`` object from the given key-value-pairs.
    /// - Parameters:
    ///   - values: The key-value-pairs to use for creating the new ``Media`` object
    ///   - context: The ``NSManagedObjectContext`` to create the media object in
    /// - Returns: The ``Media`` object
    static func createMedia(from values: [String: String], context: NSManagedObjectContext) async throws -> Media {
        // swiftlint:enable cyclomatic_complexity function_body_length
        
        // We only need the tmdbID and user values from the CSV
        guard let tmdbIDValue = values[.tmdbID], let tmdbID = Int(tmdbIDValue) else {
            throw CSVError.noTMDBID
        }
        guard let mediaTypeValue = values[.mediaType], let mediaType = MediaType(rawValue: mediaTypeValue) else {
            throw CSVError.noMediaType
        }
        
        // Check if media with this tmdbID already exists
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %d", "tmdbID", tmdbID)
        fetchRequest.fetchLimit = 1
        let existingAmount = (try? context.count(for: fetchRequest)) ?? 0
        if existingAmount > 0 {
            // Media already exists in context
            throw CSVError.mediaAlreadyExists
        }
        
        // Create the media
        let media = try await TMDBAPI.shared.media(for: tmdbID, type: mediaType, context: context)
        
        // Setting values with PartialKeyPaths is not possible, so we have to do it manually
        // Specifying ReferenceWritableKeyPaths in the dictionary with the converters is not possible, since the dictionary Value type would not be identical then
        if
            let rawRating = values[.personalRating],
            let intRep = Int(rawRating),
            let personalRating = StarRating(integerRepresentation: intRep)
        {
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
        if let rawWatched = values[.movieWatched], let watched = MovieWatchState(rawValue: rawWatched) {
            assert(mediaType == .movie)
            if let movie = media as? Movie {
                movie.watched = watched
            }
        }
        // Legacy show watch state import
        if let rawWatched = values[.showWatched], let watched = ShowWatchState(rawValue: rawWatched) {
            assert(mediaType == .show)
            if let show = media as? Show {
                show.watched = watched
            }
        }
        // New show watch state import
        if let rawLastSeasonWatched = values[.lastSeasonWatched], let lastSeasonWatched = Int(rawLastSeasonWatched) {
            let rawLastEpisodeWatched = values[.lastEpisodeWatched]
            let lastEpisodeWatched = rawLastEpisodeWatched == nil ? nil : Int(rawLastEpisodeWatched!)
            
            assert(mediaType == .show)
            if let show = media as? Show {
                show.watched = .init(season: lastSeasonWatched, episode: lastEpisodeWatched)
            }
        }
        if
            let rawCreationDate = values[.creationDate],
            let creationDate = dateTimeFormatter.date(from: rawCreationDate)
        {
            media.creationDate = creationDate
        }
        if
            let rawModificationDate = values[.modificationDate],
            let modificationDate = dateTimeFormatter.date(from: rawModificationDate)
        {
            media.modificationDate = modificationDate
        }
        
        await media.loadThumbnail()
        
        return media
    }
    
    // swiftlint:disable cyclomatic_complexity
    /// Creates a CSV record (line) from the given media object
    /// - Parameter media: The media object to export
    /// - Returns: The CSV line as a dictionary with all string values, keyed by their CSV header
    static func createRecord(from media: Media) -> [CSVKey: String] {
        // swiftlint:enable cyclomatic_complexity
        var values: [CSVKey: String] = [:]
        for key in exportKeys {
            var tuple: (Any, Converter?)?
            
            // Extract the value by reading the KeyPath; Pass the converter to the tuple
            if let (keyPath, conv) = exportKeyPaths[key] {
                let value = media[keyPath: keyPath]
                tuple = (value, conv)
            } else if let (keyPath, conv) = movieExclusiveExportKeyPaths[key] {
                if let movie = media as? Movie {
                    let value = movie[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Movie, we leave the value blank
                    tuple = ("", nil)
                }
            } else if let (keyPath, conv) = showExclusiveExportKeyPaths[key] {
                if let show = media as? Show {
                    let value = show[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Show, we leave the value blank
                    tuple = ("", nil)
                }
            } else {
                fatalError("The key \(key) has no assigned KeyPath. Please add the key to one of the following " +
                    "dictionaries: keyPaths, movieExclusiveKeyPaths or showExclusiveKeyPaths.")
            }
            
            // Unwrap the value and converter
            var (value, converter) = tuple!
            
            // Convert the value, if a converter was given (and the value is not nil)
            if converter == nil {
                // Default converter
                converter = { "\($0)" }
            }
            
            // Convert the value to a string (and convert nil to "")
            var stringValue: String
            switch value {
            case Optional<Any>.none:
                // Map nil to ""
                stringValue = ""
            // Optional with value `some` or no Optional at all
            default:
                // Create a mirror of the object to read the `some` property of the Optional
                let mirror = Mirror(reflecting: value)
                // If value is an Optional
                if mirror.displayStyle == .optional {
                    // Since `value` is an Optional, it has exactly one property (`some`)
                    let unwrapped = mirror.children.first?.value
                    stringValue = converter!(unwrapped ?? "")
                } else {
                    // If value is no Optional, we don't need to unwrap it
                    stringValue = converter!(value)
                }
            }
            
            // Double all quotation marks in the value (escape them)
            stringValue = stringValue.replacingOccurrences(of: "\"", with: "\"\"")
            
            // If the value contains a separator, encapsulate the value in quotation marks
            if stringValue.contains(separator) {
                stringValue = "\"\(stringValue)\""
            }
            
            // Replace newlines and "\n"'s with spaces to prevent messing up the CSV file
            let regex = Regex {
                ChoiceOf {
                    OneOrMore(.newlineSequence)
                    OneOrMore("\\n") // "\n" string, not newline char
                }
            }
            stringValue.replace(regex) { _ in " " }
            
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
        csv.append(exportKeys.map(\.rawValue).joined(separator: separator))
        // CSV Values
        for mediaObject in mediaObjects {
            let values = createRecord(from: mediaObject)
            let line: [String] = exportKeys.map { values[$0]! }
            csv.append(line.joined(separator: separator))
        }
        return csv.joined(separator: lineSeparator)
    }
    
    enum CSVKey: String, CaseIterable {
        // Import
        case tmdbID = "tmdb_id"
        case mediaType = "type"
        case personalRating = "personal_rating"
        case watchAgain = "watch_again"
        case tags
        case notes
        // Movie exclusive
        case movieWatched = "movie_watched"
        // Show exclusive
        case showWatched = "show_watched"
        case lastSeasonWatched = "last_season_watched"
        case lastEpisodeWatched = "last_episode_watched"
        
        // Export only
        case id
        case tagline
        case title
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
        case createdBy = "created_by"
        
        case creationDate = "creation_date"
        case modificationDate = "modification_date"
    }
    
    enum CSVError: Error {
        case noTMDBID
        case noMediaType
        case mediaAlreadyExists
    }
}

private extension Dictionary where Key == String {
    subscript(key: CSVManager.CSVKey) -> Value? {
        get {
            self[key.rawValue]
        }
        set(newValue) {
            self[key.rawValue] = newValue
        }
    }
}
