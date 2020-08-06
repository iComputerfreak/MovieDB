//
//  CSVData.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

struct CSVData {
    
    enum CSVDataError: Error {
        case missingValue(String)
    }
    
    let id: Int
    let type: MediaType
    let personalRating: StarRating
    let tags: [Int]
    let watchAgain: Bool?
    let notes: String
    
    let tmdbID: Int
    let title: String
    let originalTitle: String
    let genres: [Genre]
    let overview: String?
    let status: MediaStatus
    
    let watched: Bool?
    let releaseDate: Date?
    let runtime: Int?
    let budget: Int? // Optional, because it's movie specific
    let revenue: Int? // Optional, because it's movie specific
    let isAdult: Bool? // Optional, because it's movie specific
    
    let lastEpisodeWatched: Show.EpisodeNumber?
    let firstAirDate: Date?
    let lastAirDate: Date?
    let numberOfSeasons: Int?
    let isInProduction: Bool? // Optional, because it's show specific
    let showType: ShowType?
    
    let dateFormatter: DateFormatter
    let separator: String
    let arraySeparator: String
    let lineSeparator: String
    
    init(from media: Media, dateFormatter: DateFormatter, separator: String, arraySeparator: String, lineSeparator: String) throws {
        self.id = media.id
        self.type = media.type
        self.personalRating = media.personalRating
        self.tags = media.tags
        self.watchAgain = media.watchAgain
        self.notes = media.notes
        guard let tmdbData = media.tmdbData else {
            throw CSVDataError.missingValue("Media \(media.id) has no tmdbData.")
        }
        self.tmdbID = tmdbData.id
        self.title = tmdbData.title
        self.originalTitle = tmdbData.originalTitle
        self.genres = tmdbData.genres
        self.overview = tmdbData.overview
        self.status = tmdbData.status
        
        let movieData = tmdbData as? TMDBMovieData
        self.watched = (media as? Movie)?.watched
        self.releaseDate = movieData?.releaseDate
        self.runtime = movieData?.runtime
        self.budget = movieData?.budget
        self.revenue = movieData?.revenue
        self.isAdult = movieData?.isAdult
        
        let showData = tmdbData as? TMDBShowData
        self.lastEpisodeWatched = (media as? Show)?.lastEpisodeWatched
        self.firstAirDate = showData?.firstAirDate
        self.lastAirDate = showData?.lastAirDate
        self.numberOfSeasons = showData?.numberOfSeasons
        self.isInProduction = showData?.isInProduction
        self.showType = showData?.type
        
        self.dateFormatter = dateFormatter
        self.separator = separator
        self.arraySeparator = arraySeparator
        self.lineSeparator = lineSeparator
    }
    
    func createCSVValues() -> [String: String] {
        var encoder = CSVEncoder(arraySeparator: arraySeparator)
        
        encoder.encode(id, forKey: .id)
        encoder.encode(type, forKey: .type)
        encoder.encode(personalRating, forKey: .personalRating)
        // We don't export tags, that don't have a name
        encoder.encode(tags.compactMap({ TagLibrary.shared.name(for: $0)?.cleaned(of: separator, arraySeparator, lineSeparator) }), forKey: .tags)
        encoder.encode(watchAgain, forKey: .watchAgain)
        // Clean the notes (should not contains illegal characters)
        encoder.encode(notes.cleaned(of: separator, arraySeparator, lineSeparator), forKey: .notes)
        encoder.encode(tmdbID, forKey: .tmdbID)
        encoder.encode(title.cleaned(of: separator, arraySeparator, lineSeparator), forKey: .title)
        encoder.encode(originalTitle.cleaned(of: separator, arraySeparator, lineSeparator), forKey: .originalTitle)
        encoder.encode(genres.map(\.name), forKey: .genres)
        encoder.encode(overview?.cleaned(of: separator, arraySeparator, lineSeparator), forKey: .overview)
        encoder.encode(status, forKey: .status)
        
        encoder.encode(watched, forKey: .watched)
        let rawReleaseDate = releaseDate == nil ? nil : dateFormatter.string(from: releaseDate!)
        encoder.encode(rawReleaseDate, forKey: .releaseDate)
        encoder.encode(runtime, forKey: .runtime)
        encoder.encode(budget, forKey: .budget)
        encoder.encode(revenue, forKey: .revenue)
        encoder.encode(isAdult, forKey: .isAdult)
        
        encoder.encode(lastEpisodeWatched, forKey: .lastEpisodeWatched)
        let rawFirstAirDate = firstAirDate == nil ? nil : dateFormatter.string(from: firstAirDate!)
        encoder.encode(rawFirstAirDate, forKey: .firstAirDate)
        let rawLastAirDate = lastAirDate == nil ? nil : dateFormatter.string(from: lastAirDate!)
        encoder.encode(rawLastAirDate, forKey: .lastAirDate)
        encoder.encode(numberOfSeasons, forKey: .numberOfSeasons)
        encoder.encode(isInProduction, forKey: .isInProduction)
        encoder.encode(showType, forKey: .showType)
        
        return encoder.data
    }
    
    static func createMedia(from data: [String: String], arraySeparator: String) throws -> Media? {
        let decoder = CSVDecoder(data: data, arraySeparator: arraySeparator)
        
        let type = try decoder.decode(MediaType.self, forKey: .type)
        let personalRating = try decoder.decode(StarRating.self, forKey: .personalRating)
        
        let tagNames = try decoder.decode([String].self, forKey: .tags)
        var tagIDs = [Int]()
        for name in tagNames {
            if let id = TagLibrary.shared.tags.first(where: { $0.name == name })?.id {
                tagIDs.append(id)
            } else {
                // Tag does not exist, create a new one
                let id = TagLibrary.shared.create(name: name)
                tagIDs.append(id)
            }
        }
        let tags = tagIDs
        
        let watchAgain = try decoder.decode(Bool?.self, forKey: .watchAgain)
        let notes = try decoder.decode(String.self, forKey: .notes)
        let watched = try decoder.decode(Bool?.self, forKey: .watched)
        let lastEpisodeWatched = try decoder.decode(Show.EpisodeNumber?.self, forKey: .lastEpisodeWatched)
        
        // To create the media, we fetch it from the API and then assign the user values
        let tmdbID = try decoder.decode(Int.self, forKey: .tmdbID)
        let media = try TMDBAPI.shared.fetchMedia(id: tmdbID, type: type)
        media.personalRating = personalRating
        media.tags = tags
        media.watchAgain = watchAgain
        media.notes = notes
        
        if type == .movie {
            assert(Swift.type(of: media) == Movie.self)
            (media as? Movie)?.watched = watched
        } else {
            assert(Swift.type(of: media) == Show.self)
            (media as? Show)?.lastEpisodeWatched = lastEpisodeWatched
        }
        
        return media
    }
}

fileprivate extension String {
    /// Removes the occurrences of all given strings from this string
    /// - Parameter strings: The array of strings to remove
    /// - Returns: The string, cleaned from all occurrences of the strings given
    func cleaned(of strings: String...) -> String {
        var returnValue = self
        for string in strings {
            returnValue = returnValue.replacingOccurrences(of: string, with: "")
        }
        return returnValue
    }
}
