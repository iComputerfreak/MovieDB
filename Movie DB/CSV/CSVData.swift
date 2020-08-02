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
    let arraySeparator: String
    
    
    init(from media: Media, dateFormatter: DateFormatter, arraySeparator: String) throws {
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
        self.arraySeparator = arraySeparator
    }
    
    /// Creates a new CSVData object from the given set of string values
    init(from data: [String: String], dateFormatter: DateFormatter, arraySeparator: String) throws {
        let decoder = CSVDecoder(data: data, arraySeparator: arraySeparator)
        
        self.id = try decoder.decode(Int.self, forKey: .id)
        self.type = try decoder.decode(MediaType.self, forKey: .type)
        self.personalRating = try decoder.decode(StarRating.self, forKey: .personalRating)
        self.tags = try decoder.decode([Int].self, forKey: .tags)
        self.watchAgain = try decoder.decode(Bool?.self, forKey: .watchAgain)
        self.notes = try decoder.decode(String.self, forKey: .notes)
        
        self.tmdbID = try decoder.decode(Int.self, forKey: .tmdbID)
        self.title = try decoder.decode(String.self, forKey: .title)
        self.originalTitle = try decoder.decode(String.self, forKey: .originalTitle)
        self.genres = try decoder.decode([Genre].self, forKey: .genres)
        self.overview = try decoder.decode(String?.self, forKey: .overview)
        self.status = try decoder.decode(MediaStatus.self, forKey: .status)
        
        // Movie exclusive (all optional, because the current media could be a show)
        self.watched = try decoder.decode(Bool?.self, forKey: .watched)
        if let rawReleaseDate = try decoder.decode(String?.self, forKey: .releaseDate) {
            self.releaseDate = dateFormatter.date(from: rawReleaseDate)
        } else {
            self.releaseDate = nil
        }
        self.runtime = try decoder.decode(Int?.self, forKey: .runtime)
        self.budget = try decoder.decode(Int?.self, forKey: .budget)
        self.revenue = try decoder.decode(Int?.self, forKey: .revenue)
        self.isAdult = try decoder.decode(Bool?.self, forKey: .isAdult)
        
        // Show exclusive (all optional, because the current media could be a movie)
        self.lastEpisodeWatched = try decoder.decode(Show.EpisodeNumber.self, forKey: .lastEpisodeWatched)
        if let rawFirstAirDate = try decoder.decode(String?.self, forKey: .firstAirDate) {
            self.firstAirDate = dateFormatter.date(from: rawFirstAirDate)
        } else {
            self.firstAirDate = nil
        }
        if let rawLastAirDate = try decoder.decode(String?.self, forKey: .lastAirDate) {
            self.lastAirDate = dateFormatter.date(from: rawLastAirDate)
        } else {
            self.lastAirDate = nil
        }
        self.numberOfSeasons = try decoder.decode(Int?.self, forKey: .numberOfSeasons)
        self.isInProduction = try decoder.decode(Bool?.self, forKey: .isInProduction)
        self.showType = try decoder.decode(ShowType?.self, forKey: .showType)
        
        self.dateFormatter = dateFormatter
        self.arraySeparator = arraySeparator
    }
    
    func createCSV() -> [String: String] {
        var encoder = CSVEncoder(arraySeparator: arraySeparator)
        
        encoder.encode(id, forKey: .id)
        encoder.encode(type, forKey: .type)
        encoder.encode(personalRating, forKey: .personalRating)
        encoder.encode(tags, forKey: .tags)
        encoder.encode(watchAgain, forKey: .watchAgain)
        encoder.encode(notes, forKey: .notes)
        encoder.encode(tmdbID, forKey: .tmdbID)
        encoder.encode(title, forKey: .title)
        encoder.encode(originalTitle, forKey: .originalTitle)
        encoder.encode(overview, forKey: .overview)
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
    
    func createMedia() -> Media? {
        // To create the media, we fetch it from the API and then assign the user values
        let media = TMDBAPI.shared.fetchMedia(id: self.tmdbID, type: self.type)
        media?.personalRating = self.personalRating
        media?.tags = self.tags
        media?.watchAgain = self.watchAgain
        media?.notes = self.notes
        
        if type == .movie {
            assert(Swift.type(of: media) == Movie.self)
            (media as? Movie)?.watched = self.watched
        } else {
            assert(Swift.type(of: media) == Show.self)
            (media as? Show)?.lastEpisodeWatched = self.lastEpisodeWatched
        }
        
        return media
    }
}
