//
//  TestingUtils.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

@testable import Movie_DB

import CoreData
import Testing

struct TestingUtils {
    let context: NSManagedObjectContext
    
    let previewTags: Set<Movie_DB.Tag>
    let matrixMovie: Movie
    let fightClubMovie: Movie
    let blacklistShow: Show // swiftlint:disable:this inclusive_language
    let gameOfThronesShow: Show
    var mediaSamples: [Media]
    
    init() {
        let context = PersistenceController.createTestingContext()
        self.context = context
        let previewTags: Set<Movie_DB.Tag> = [
            Tag(name: "Future", context: context),
            Tag(name: "Conspiracy", context: context),
            Tag(name: "Dark", context: context),
            Tag(name: "Violent", context: context),
            Tag(name: "Gangsters", context: context),
            Tag(name: "Terrorist", context: context),
            Tag(name: "Past", context: context),
            Tag(name: "Fantasy", context: context),
        ]
        self.previewTags = previewTags
        matrixMovie = {
            let tmdbData: TMDBData = Self.load("Matrix.json", mediaType: .movie, into: context)
            let m = Movie(context: context, tmdbData: tmdbData)
            m.personalRating = .twoAndAHalfStars
            m.tags = Self.getPreviewTags(["Future", "Conspiracy", "Dark"], of: previewTags)
            m.notes = ""
            m.watched = .watched
            m.watchAgain = false
            return m
        }()
        fightClubMovie = {
            let tmdbData: TMDBData = Self.load("FightClub.json", mediaType: .movie, into: context)
            let m = Movie(context: context, tmdbData: tmdbData)
            m.personalRating = .noRating
            m.tags = Self.getPreviewTags(["Dark", "Violent"], of: previewTags)
            m.notes = "Never watched it..."
            m.watched = .notWatched
            m.watchAgain = nil
            return m
        }()
        blacklistShow = {
            let tmdbData: TMDBData = Self.load("Blacklist.json", mediaType: .show, into: context)
            let s = Show(context: context, tmdbData: tmdbData)
            s.personalRating = .fiveStars
            s.tags = Self.getPreviewTags(["Gangsters", "Conspiracy", "Terrorist"], of: previewTags)
            s.notes = "A masterpiece!"
            s.watched = .season(7)
            s.watchAgain = true
            return s
        }()
        gameOfThronesShow = {
            let tmdbData: TMDBData = Self.load("GameOfThrones.json", mediaType: .show, into: context)
            let s = Show(context: context, tmdbData: tmdbData)
            s.personalRating = .twoAndAHalfStars
            s.tags = Self.getPreviewTags(["Past", "Fantasy"], of: previewTags)
            s.notes = "Bad ending"
            s.watched = .episode(season: 8, episode: 3)
            s.watchAgain = false
            return s
        }()
        mediaSamples = [matrixMovie, fightClubMovie, blacklistShow, gameOfThronesShow]
    }
    
    static func load<T: Decodable>(
        _ filename: String,
        mediaType: MediaType? = nil,
        into context: NSManagedObjectContext,
        as type: T.Type = T.self
    ) -> T {
        let data: Data
        
        guard
            let file = Bundle(for: APITests.self).url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in test bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from test bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = context
            decoder.userInfo[.mediaType] = mediaType
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static func getPreviewTags(_ tagNames: [String], of tags: Set<Movie_DB.Tag>) -> Set<Movie_DB.Tag> {
        Set(tagNames.map { name in
            guard let tag = tags.first(where: \.name, equals: name) else {
                fatalError("Preview Tag \(name) does not exist.")
            }
            return tag
        })
    }
                     
    func getPreviewTags(_ tagNames: [String]) -> Set<Movie_DB.Tag> {
        Self.getPreviewTags(tagNames, of: previewTags)
    }
}

// MARK: - Global Testing Utilities

/// Tests each element of the array by itself, to get a more local error
func assertEqual<T>(_ value1: [T], _ value2: [T]) where T: Equatable {
    guard value1.count == value2.count else {
        #expect(Bool(false), "Cannot compare arrays of different lenghts: \(value1.count) and \(value2.count)")
        return
    }
    for i in 0..<value1.count {
        #expect(value1[i] == value2[i])
    }
}

/// Tests if a date equals the given components
func assertEqual(_ date: Date?, _ year: Int, _ month: Int, _ day: Int) {
    #expect(date != nil)
    var cal = Calendar.current
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    #expect(cal.component(.year, from: date!) == year)
    #expect(cal.component(.month, from: date!) == month)
    #expect(cal.component(.day, from: date!) == day)
}

/// Tests, if the first array is completely part of the other array
func assertContains<T>(_ value: [T], in other: [T]) where T: Equatable {
    #expect(value.count <= other.count)
    for element in value {
        #expect(other.contains(element), "\(element) not found.")
    }
}

extension SeasonDummy {
    init(
        id: Int,
        seasonNumber: Int,
        episodeCount: Int,
        name: String,
        overview: String?,
        imagePath: String?,
        rawAirDate: String?
    ) {
        let airDate = rawAirDate.map { Utils.tmdbUTCDateFormatter.date(from: $0) }
        self.init(
            id: id,
            seasonNumber: seasonNumber,
            episodeCount: episodeCount,
            name: name,
            overview: overview,
            imagePath: imagePath,
            // swiftlint:disable:next redundant_nil_coalescing
            airDate: airDate ?? nil
        )
    }
}

extension Movie {
    convenience init(
        context: NSManagedObjectContext,
        id: Int = Int.random(in: 0...Int.max),
        title: String = "Test Media",
        originalTitle: String = "Test Media",
        imagePath: String? = nil,
        genres: [GenreDummy] = [],
        tagline: String? = nil,
        overview: String? = nil,
        status: MediaStatus = .released,
        originalLanguage: String = "",
        productionCompanies: [ProductionCompanyDummy] = [],
        homepageURL: String? = nil,
        productionCountries: [String] = [],
        popularity: Float = 0,
        voteAverage: Float = 0,
        voteCount: Int = 0,
        keywords: [String] = [],
        translations: [String] = [],
        videos: [VideoDummy] = [],
        parentalRating: ParentalRatingDummy? = nil,
        watchProviders: [WatchProviderDummy] = [],
        movieData: TMDBData.MovieData? = .init(rawReleaseDate: "2022-01-01", budget: 0, revenue: 0, isAdult: false, directors: ["John Doe"]),
        showData: TMDBData.ShowData? = nil
    ) {
        self.init(context: context, tmdbData: TMDBData(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: imagePath,
            genres: genres,
            tagline: tagline,
            overview: overview,
            status: status,
            originalLanguage: originalLanguage,
            productionCompanies: productionCompanies,
            homepageURL: homepageURL,
            productionCountries: productionCountries,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount,
            keywords: keywords,
            translations: translations,
            videos: videos,
            parentalRating: parentalRating,
            watchProviders: watchProviders,
            movieData: movieData,
            showData: showData
        ))
    }
}

extension Show {
    convenience init(
        context: NSManagedObjectContext,
        id: Int = Int.random(in: 0...Int.max),
        title: String = "Test Media",
        originalTitle: String = "Test Media",
        imagePath: String? = nil,
        genres: [GenreDummy] = [],
        tagline: String? = nil,
        overview: String? = nil,
        status: MediaStatus = .released,
        originalLanguage: String = "",
        productionCompanies: [ProductionCompanyDummy] = [],
        homepageURL: String? = nil,
        productionCountries: [String] = [],
        popularity: Float = 0,
        voteAverage: Float = 0,
        voteCount: Int = 0,
        keywords: [String] = [],
        translations: [String] = [],
        videos: [VideoDummy] = [],
        parentalRating: ParentalRatingDummy? = nil,
        watchProviders: [WatchProviderDummy] = [],
        movieData: TMDBData.MovieData? = nil,
        showData: TMDBData.ShowData? = .init(rawFirstAirDate: "2022-01-01", rawLastAirDate: "2022-01-01", numberOfEpisodes: 0, episodeRuntime: [], isInProduction: false, seasons: [], networks: [], createdBy: [])
    ) {
        self.init(context: context, tmdbData: TMDBData(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: imagePath,
            genres: genres,
            tagline: tagline,
            overview: overview,
            status: status,
            originalLanguage: originalLanguage,
            productionCompanies: productionCompanies,
            homepageURL: homepageURL,
            productionCountries: productionCountries,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount,
            keywords: keywords,
            translations: translations,
            videos: videos,
            parentalRating: parentalRating,
            watchProviders: watchProviders,
            movieData: movieData,
            showData: showData
        ))
    }
}
