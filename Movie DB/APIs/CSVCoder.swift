//
//  CSVEncoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.02.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

fileprivate enum CodingKeys: String {
    case id
    case type
    case personalRating
    case tags
    case watchAgain
    case notes
    
    case tmdbID
    case title
    case originalTitle
    case genres
    case overview
    case status
    // Movie only
    case watched
    case releaseDate
    case runtime
    case budget
    case revenue
    case isAdult
    // Show only
    case lastEpisodeWatched
    case firstAirDate
    case lastAirDate
    case numberOfSeasons
    case isInProduction
    case showType
}

fileprivate let arraySeparator: Character = ","
fileprivate let separator: Character = ";"
fileprivate let delimiter: Character = "\n"

fileprivate let headers: [CodingKeys] = [
    .id, .tmdbID, .type, .title, .personalRating, .watchAgain, .tags, .notes, .originalTitle, .genres, .overview, .status, // Common
    .watched, .releaseDate, .runtime, .budget, .revenue, .isAdult, // Movie exclusive
    .lastEpisodeWatched, .firstAirDate, .lastAirDate, .numberOfSeasons, .isInProduction, .showType // Show exclusive
]
fileprivate var header: String { headers.map(\.rawValue).joined(separator: String(separator)) }

struct CSVEncoder {
    
    // TODO: We should probably use a dictionary instead of a array here. (Use CodingKeys enum as keys and maybe use Codable)
    func encode(_ mediaObjects: [Media]) -> String {
        var lines: [String] = [header]
        for mediaObject in mediaObjects {
            var values: [String] = []
            
            // General values
            values.append(String(mediaObject.id))
            if let id = mediaObject.tmdbData?.id {
                values.append(String(id))
            } else { values.append("") }
            values.append(mediaObject.type.rawValue)
            if let title = mediaObject.tmdbData?.title {
                values.append(title)
            } else { values.append("") }
            values.append(String(mediaObject.personalRating.integerRepresentation))
            values.append(convert(mediaObject.watchAgain))
            values.append(mediaObject.tags.compactMap({ TagLibrary.shared.name(for: $0) }).joined(separator: String(arraySeparator)))
            values.append(clean(mediaObject.notes))
            if let tmdbData = mediaObject.tmdbData {
                values.append(tmdbData.originalTitle)
                values.append(tmdbData.genres.map(\.name).joined(separator: String(arraySeparator)))
                values.append(clean(tmdbData.overview ?? ""))
                values.append(tmdbData.status.rawValue)
            } else {
                for _ in 1...4 { values.append("") }
            }
            
            // Movie only values
            if let movie = mediaObject as? Movie {
                values.append(convert(movie.watched))
            } else { values.append("") }
            if let tmdbData = mediaObject.tmdbData as? TMDBMovieData {
                if let date = tmdbData.releaseDate {
                    values.append("\(date)")
                } else {
                    values.append("")
                }
                values.append(convert(tmdbData.runtime))
                values.append(convert(tmdbData.budget))
                values.append(convert(tmdbData.revenue))
                values.append(convert(tmdbData.isAdult))
            } else {
                for _ in 1...5 { values.append("") }
            }
            
            // Show only values
            if let show = mediaObject as? Show {
                if let lastWatched = show.lastEpisodeWatched {
                    values.append("\(lastWatched.season)\(lastWatched.episode != nil ? "-\(lastWatched.episode!)" : "")")
                } else {
                    values.append("")
                }
            } else {
                values.append("")
            }
            if let tmdbData = mediaObject.tmdbData as? TMDBShowData {
                if let firstAirDate = tmdbData.firstAirDate {
                    values.append("\(firstAirDate)")
                } else {
                    values.append("")
                }
                if let lastAirDate = tmdbData.lastAirDate {
                    values.append("\(lastAirDate)")
                } else {
                    values.append("")
                }
                values.append(convert(tmdbData.numberOfSeasons))
                values.append(convert(tmdbData.isInProduction))
                values.append(tmdbData.type?.rawValue ?? "")
            } else {
                for _ in 1...5 { values.append("") }
            }
        
            guard values.count == headers.count else {
                print("Number of values (\(values.count)) do not match the number of header fields (\(headers.count)). Aborting...")
                return ""
            }
            
            lines.append(values.joined(separator: String(separator)))
        }
        return lines.joined(separator: String(delimiter))
    }
    
    /// Removes separator and delimiter symbols and replaces them with appropriate other symbols
    private func clean(_ value: String) -> String {
        return value
            .replacingOccurrences(of: String(separator), with: ",")
            .replacingOccurrences(of: String(delimiter), with: " ")
    }
    
    private func convert<T>(_ value: T?) -> String where T: CustomStringConvertible {
        if value == nil {
            return ""
        }
        return convert(value!)
    }
    
    private func convert<T>(_ value: T) -> String where T: CustomStringConvertible {
        if T.self == Bool.self {
            return (value as! Bool) ? "1" : "0"
        } else if T.self == Int.self {
            return String(value as! Int)
        }
        return String(describing: value)
    }
    
}

struct CSVDecoder {
    
    func decode(_ csv: String) -> [Media] {
        var mediaObjects: [Media] = []
        
        // Drop the first line, as it is the header
        for line in csv.components(separatedBy: String(delimiter)).dropFirst() {
            if let dict = translate(from: line.components(separatedBy: String(separator))) {
                var mediaType: MediaType? = nil
                if dict[.type] == MediaType.movie.rawValue {
                    mediaType = .movie
                } else {
                    mediaType = .show
                }
                
                // Without the media type and TMDB ID, we cannot recover the media
                guard mediaType != nil else {
                    print("Unable to recover media type '\(dict[.type] ?? "nil")'")
                    continue
                }
                guard let tmdbID = Int(dict[.tmdbID] ?? "") else {
                    print("Unable to recover tmdb ID '\(dict[.tmdbID] ?? "nil")'")
                    continue
                }
                
                // Fetch the media before filling in the loaded data
                guard let mediaObject = TMDBAPI.shared.fetchMedia(id: tmdbID, type: mediaType!) else {
                    print("Unable to fetch media object with TMDB ID \(tmdbID).")
                    continue
                }
                
                // Input the relevant values
                // Ignore the ID, a new ID will be issued automatically
                if let rating = Int(dict[.personalRating] ?? "") {
                    mediaObject.personalRating = StarRating(integerRepresentation: rating) ?? .noRating
                }
                if let watchAgain = Int(dict[.watchAgain] ?? "") {
                    if watchAgain == 0 {
                        mediaObject.watchAgain = false
                    } else if watchAgain == 1 {
                        mediaObject.watchAgain = true
                    }
                }
                if let tags = dict[.tags] {
                    // Map the tag names to their IDs
                    mediaObject.tags = tags.components(separatedBy: String(arraySeparator)).compactMap { name in
                        guard !name.isEmpty else {
                            return nil
                        }
                        // If no tag with this name exists, create a new one
                        if !TagLibrary.shared.tags.map(\.name).contains(name) {
                            TagLibrary.shared.create(name: name)
                        }
                        let tags = TagLibrary.shared.tags.first(where: { $0.name == name })?.id
                        assert(tags != nil, "Tag is missing, although it has been created just now.")
                        return tags
                    }
                }
                if let notes = dict[.notes] {
                    mediaObject.notes = notes
                }
                
                // Movie and Show exclusive data
                if let movie = mediaObject as? Movie {
                    movie.watched = convert(dict[.watched])
                } else if let show = mediaObject as? Show {
                    show.lastEpisodeWatched = convert(dict[.lastEpisodeWatched])
                }
                
                mediaObjects.append(mediaObject)
            }
        }
        
        return mediaObjects
    }
    
    private func convert(_ value: String?) -> Bool? {
        if let value = Int(value ?? "") {
            if value == 0 {
                return false
            } else if value == 1 {
                return true
            }
        }
        return nil
    }
    
    private func convert(_ value: String?) -> Show.EpisodeNumber? {
        guard let value = value else {
            return nil
        }
        let parts = value.components(separatedBy: "-")
        if parts.count == 1 {
            if let season = Int(parts[0]) {
                return Show.EpisodeNumber(season: season)
            }
        } else if parts.count == 2 {
            if let season = Int(parts[0]), let episode = Int(parts[1]) {
                return Show.EpisodeNumber(season: season, episode: episode)
            }
        }
        return nil
    }
    
    /// Translates the given array of csv values into a dictionary using the defined headers
    /// - Parameter values: The values to translate
    private func translate(from values: [String]) -> [CodingKeys: String]? {
        guard values.count == headers.count else {
            print("Error translating line. Array count (\(values.count)) does not match headers count (\(headers.count)).")
            return nil
        }
        var it = headers.makeIterator()
        var dict: [CodingKeys: String] = [:]
        for value in values {
            dict[it.next()!] = value
        }
        return dict
    }
    
}
