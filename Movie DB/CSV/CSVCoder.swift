//
//  CSVCoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

/// Handles de- and encoding of media objects into CSV strings
struct CSVCoder {
    
    enum CSVCoderError: Error {
        case invalidHeader(String)
        case dataCorrupted(String)
    }
    
    /// The headers that are used for de- and encoding
    var headers: [CSVCodingKey] = [
        .id, .tmdbID, .type, .title, .personalRating, .watchAgain, .tags, .notes, .originalTitle, .genres, .overview, .status, // Common
        .watched, .releaseDate, .runtime, .budget, .revenue, .isAdult, // Movie exclusive
        .lastEpisodeWatched, .firstAirDate, .lastAirDate, .numberOfSeasons, .isInProduction, .showType // Show exclusive
    ]
    
    /// The CSV separator
    var separator = ";"
    /// The separator used for de- and encoding arrays
    var arraySeparator = ","
    /// The line separator
    let lineSeparator = "\n"
    
    /// The `DateFormatter` used for de- and encoding dates
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Decodes a given CSV string into media objects
    /// - Parameter csv: The CSV string
    /// - Throws: `TMDBAPI.APIError` or `CSVDecodingError`
    /// - Returns: The decoded media objects
    func decode(_ csv: String) throws -> [Media] {
        // Remove Carriage Returns (the file may be CRLF encoded)
        var lines = csv.components(separatedBy: lineSeparator).map({ $0.trimmingCharacters(in: CharacterSet(charactersIn: "\r")) })
        var mediaObjects: [Media] = []
        
        // Load the headers from the CSV
        let headers: [CSVCodingKey] = try lines.removeFirst().components(separatedBy: separator).map({ rawValue in
            guard let value = CSVCodingKey(rawValue: rawValue) else {
                throw CSVCoderError.invalidHeader(rawValue)
            }
            return value
        })
        
        for line in lines {
            let lineParts = line.components(separatedBy: separator)
            guard headers.count == lineParts.count else {
                // Not enough or too many values in this line
                throw CSVCoderError.dataCorrupted("Header count: \(headers.count), Value count: \(lineParts.count), Line: \(line)")
            }
            let valuePairs = (0..<headers.count).map({ (headers[$0].rawValue, lineParts[$0]) })
            let values = Dictionary(uniqueKeysWithValues: valuePairs)
            
            let media = try CSVData.createMedia(from: values, arraySeparator: arraySeparator)
            mediaObjects.append(media)
        }
        
        return mediaObjects
    }
    
    /// Encodes the given media objects into a CSV string
    /// - Parameter mediaObjects: The media objects to encode
    /// - Throws: `TMDBAPI.APIError` or `CSVDecodingError`
    /// - Returns: The CSV string
    func encode(_ mediaObjects: [Media]) throws -> String {
        // Start with the header line
        var lines: [String] = [headers.map(\.rawValue).joined(separator: separator)]
        
        let sortedMedia = mediaObjects.sorted { (media1, media2) in
            return media1.title.lexicographicallyPrecedes(media2.title)
        }
        for media in sortedMedia {
            let data = try CSVData(from: media, dateFormatter: dateFormatter, separator: separator, arraySeparator: arraySeparator, lineSeparator: lineSeparator)
            // Export CSVData as String
            let values = data.createCSVValues()
            // Map the headers to their value
            let csv = headers.map({ values[$0] ?? "" }).joined(separator: separator)
            lines.append(csv)
        }
        
        return lines.joined(separator: lineSeparator)
    }
    
}

extension Dictionary where Key == String {
    
    subscript(key: CSVCodingKey) -> Value? {
        get {
            return self[key.rawValue]
        }
        set(newValue) {
            self[key.rawValue] = newValue
        }
    }
}

enum CSVCodingKey: String {
    case id
    case type
    case personalRating = "personal_rating"
    case tags
    case watchAgain = "watch_again"
    case notes
    
    case tmdbID = "tmdb_id"
    case title
    case originalTitle = "original_title"
    case genres
    case overview
    case status
    
    // Movie only
    case watched
    case releaseDate = "release_date"
    case runtime
    case budget
    case revenue
    case isAdult = "is_adult"
    
    // Show only
    case lastEpisodeWatched = "last_episode_watched"
    case firstAirDate = "first_air_date"
    case lastAirDate = "last_air_date"
    case numberOfSeasons = "number_of_seasons"
    case isInProduction = "is_in_production"
    case showType = "show_type"
}
