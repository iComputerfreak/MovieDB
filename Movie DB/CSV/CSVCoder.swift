//
//  CSVCoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

struct CSVCoder {
    
    // TODO: Replace with real API error, returned from the fetchMedia function
    // (after using errors with API)
    enum CSVCoderError: Error {
        case dataLoadError
        case invalidHeader(String)
        case dataCorrupted(String)
    }
    
    var headers: [CSVCodingKey] = [
        .id, .tmdbID, .type, .title, .personalRating, .watchAgain, .tags, .notes, .originalTitle, .genres, .overview, .status, // Common
        .watched, .releaseDate, .runtime, .budget, .revenue, .isAdult, // Movie exclusive
        .lastEpisodeWatched, .firstAirDate, .lastAirDate, .numberOfSeasons, .isInProduction, .showType // Show exclusive
    ]
    
    var arraySeparator = ","
    var separator = ";"
    var delimiter = "\n"
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func decode(_ csv: String) throws -> [Media] {
        var lines = csv.components(separatedBy: delimiter)
        var mediaObjects: [Media] = []
        
        // Load the headers from the CSV
        let headers: [CSVCodingKey] = try lines.removeFirst().components(separatedBy: separator).map({ rawValue in
            guard let value = CSVCodingKey(rawValue: rawValue) else {
                throw CSVCoderError.invalidHeader(rawValue)
            }
            return value
        })
        
        for line in lines {
            let lineParts = line.components(separatedBy: arraySeparator)
            guard headers.count == lineParts.count else {
                // Not enough or too many values in this line
                throw CSVCoderError.dataCorrupted(line)
            }
            let valuePairs = (0..<headers.count).map({ (headers[$0].rawValue, lineParts[$0]) })
            let values = Dictionary(uniqueKeysWithValues: valuePairs)
            let data = try CSVData(from: values, dateFormatter: dateFormatter, arraySeparator: arraySeparator)
            
            guard let media = data.createMedia() else {
                throw CSVCoderError.dataLoadError
            }
            mediaObjects.append(media)
        }
        
        return mediaObjects
    }
    
    func encode(_ mediaObjects: [Media]) throws -> String {
        // Start with the header line
        var lines: [String] = [headers.map(\.rawValue).joined(separator: separator)]
        
        for media in mediaObjects {
            let data = try CSVData(from: media, dateFormatter: dateFormatter, arraySeparator: arraySeparator)
            // Export CSVData as String
            let line = data.createCSV().values.joined(separator: separator)
            lines.append(line)
        }
        
        return lines.joined(separator: delimiter)
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
