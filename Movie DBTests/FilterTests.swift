//
//  FilterTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import XCTest
@testable import Movie_DB
import CoreData

class FilterTests: XCTestCase {
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    var tags: [Tag] = []
    var genres: [Genre] = []
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
        // Remove default medias and tags
        testingUtils.context.reset()
        self.tags = [
            Tag(name: "Action", context: testContext),
            Tag(name: "Adventure", context: testContext),
            Tag(name: "Horror", context: testContext),
            Tag(name: "Future", context: testContext),
            Tag(name: "Comedy", context: testContext)
        ]
        // Add sample medias to filter
        addSampleMedias()
    }
    
    private func getTags(_ names: [String]) -> Set<Tag> {
        Set(names.map { name in self.tags.first(where: { $0.name == name })! })
    }
    
    private func getGenres(_ names: [String]) throws -> Set<Genre> {
        let fetch = Genre.fetchRequest()
        fetch.predicate = NSPredicate(format: "%K IN %@", "name", names)
        let existing = try testContext.fetch(fetch)
        // TODO: Why are genres added multiple times? In production too?
        XCTAssertEqual(names.count, existing.count, "Tried fetching genres \(names.joined(separator: ", ")), but received only \(existing.count) results: \(existing.map(\.name).joined(separator: ", "))")
        return Set(existing)
    }
    
    private func createMovie(title: String, watched: MovieWatchState, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [String], rating: StarRating, year: Int, status: MediaStatus) {
        let movie = Movie(context: testContext, tmdbData: createTMDBData(type: .movie, title: title, genres: genres, year: year, status: status))
        movie.watched = watched
        movie.watchAgain = watchAgain
        movie.personalRating = rating
        movie.tags = getTags(tags)
        movie.notes = notes ?? ""
    }
    
    private func createShow(title: String, watched: EpisodeNumber?, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [String], rating: StarRating, year: Int, status: MediaStatus, showType: ShowType, seasonCount: Int) {
        let show = Show(context: testContext, tmdbData: createTMDBData(type: .show, title: title, genres: genres, year: year, status: status, seasonCount: seasonCount))
        show.lastWatched = watched
        show.watchAgain = watchAgain
        show.personalRating = rating
        show.tags = getTags(tags)
        show.notes = notes ?? ""
    }
    
    private func createTMDBData(type: MediaType, title: String, genres: [String], year: Int, status: MediaStatus, seasonCount: Int = 1) -> TMDBData {
        let date = "\(year.formatted(.number.grouping(.never)))-01-01"
        let seasons: [SeasonDummy] = (1...seasonCount).map { SeasonDummy(id: $0, seasonNumber: $0, episodeCount: 0, name: "Season \($0)", overview: nil, imagePath: nil, airDate: nil) }
        return TMDBData(
            id: Int.random(in: 1...Int.max),
            title: title,
            originalTitle: title,
            genres: genres.map { GenreDummy(id: Int.random(in: 1...Int.max), name: $0) },
            status: status,
            originalLanguage: "English",
            productionCompanies: [],
            productionCountries: [],
            popularity: 0,
            voteAverage: 0,
            voteCount: 0,
            keywords: [],
            translations: [],
            videos: [],
            watchProviders: [],
            movieData: type == .movie ? .init(rawReleaseDate: date, budget: 0, revenue: 0, isAdult: false) : nil,
            showData: type == .show ? .init(rawFirstAirDate: date, rawLastAirDate: date, numberOfEpisodes: 0, episodeRuntime: [], isInProduction: false, seasons: seasons, networks: [], createdBy: []) : nil
        )
    }
    
    private func addSampleMedias() {
        createMovie(title: "Good Movie", watched: .watched, watchAgain: true, tags: ["Action", "Adventure"], genres: ["Action", "Adventure"], rating: .fiveStars, year: 2012, status: .released)
        createMovie(title: "Bad Movie", watched: .watched, watchAgain: false, tags: ["Comedy"], genres: ["Drama"], rating: .oneAndAHalfStars, year: 1997, status: .released)
        createMovie(title: "Unwatched Movie", watched: .notWatched, watchAgain: nil, tags: ["Future", "Horror"], genres: ["Horror", "Drama", "Sci-Fi"], rating: .noRating, year: 2023, status: .inProduction)
        createShow(title: "Good Show", watched: .init(season: 5), watchAgain: true, tags: ["Comedy"], genres: ["Comedy", "Drama"], rating: .fourAndAHalfStars, year: 2015, status: .released, showType: .documentary, seasonCount: 10)
        createShow(title: "Bad Show", watched: .init(season: 1, episode: 1), watchAgain: false, tags: ["Future", "Adventure"], genres: ["Sci-Fi"], rating: .twoStars, year: 1990, status: .released, showType: .scripted, seasonCount: 3)
        createShow(title: "Unwatched Show", watched: nil, watchAgain: nil, tags: ["Future", "Horror"], genres: ["Drama"], rating: .noRating, year: 2024, status: .planned, showType: .scripted, seasonCount: 1)
    }
        
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
    }
    
    func testFilterWatched() throws {
        XCTAssertEqual(try fetch(.init(watched: true)), ["Good Movie", "Bad Movie", "Good Show", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(watched: false)), ["Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(watched: nil)), .allMedias)
    }
    
    func testFilterWatchAgain() throws {
        XCTAssertEqual(try fetch(.init(watchAgain: true)), ["Good Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(watchAgain: false)), ["Bad Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(watchAgain: nil)), .allMedias)
    }
    
    func testFilterTags() throws {
        XCTAssertEqual(try fetch(.init(tags: getTags(["Action"]))), ["Good Movie"].sorted())
        XCTAssertEqual(try fetch(.init(tags: getTags(["Adventure"]))), ["Good Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(tags: getTags(["Horror"]))), ["Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(tags: getTags(["Future"]))), ["Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(tags: getTags(["Comedy"]))), ["Bad Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(tags: [])), .allMedias)
        
        // Multiple tags (should return medias that contain any of the filtered tags)
        XCTAssertEqual(try fetch(.init(tags: getTags(["Future", "Horror"]))), ["Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(tags: getTags(["Comedy", "Action"]))), ["Good Movie", "Bad Movie", "Good Show"].sorted())
    }
    
    func testFilterMediaType() throws {
        XCTAssertEqual(try fetch(.init(mediaType: .movie)), ["Good Movie", "Bad Movie", "Unwatched Movie"].sorted())
        XCTAssertEqual(try fetch(.init(mediaType: .show)), ["Good Show", "Bad Show", "Unwatched Show"].sorted())
    }
    
    func testFilterGenres() throws {
        XCTAssertEqual(try fetch(.init(genres: getGenres(["Action"]))), ["Good Movie"].sorted())
        XCTAssertEqual(try fetch(.init(genres: getGenres(["Drama"]))), ["Bad Movie", "Unwatched Movie", "Good Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(genres: getGenres(["Sci-Fi"]))), ["Unwatched Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(genres: getGenres([]))), .allMedias)
    }
    
    private func fetch(_ filter: FilterSetting) throws -> [String] {
        let fetch = Media.fetchRequest()
        fetch.predicate = filter.predicate()
        return try testContext.fetch(fetch).map(\.title).sorted()
    }
    
    func testSaveContext() throws {
        try testContext.save()
    }
    
    func testSaveChildContext() throws {
        try testContext.newBackgroundContext().save()
    }
}

extension Array where Element == String {
    static let allMedias = ["Good Movie", "Bad Movie", "Unwatched Movie", "Good Show", "Bad Show", "Unwatched Show"].sorted()
}
