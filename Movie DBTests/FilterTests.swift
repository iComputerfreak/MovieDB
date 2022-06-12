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
        testContext.reset()
        self.tags = [
            Tag(name: "Action", context: testContext),
            Tag(name: "Adventure", context: testContext),
            Tag(name: "Horror", context: testContext),
            Tag(name: "Future", context: testContext),
            Tag(name: "Comedy", context: testContext)
        ]
        // Add sample medias to filter
        XCTAssertEqual(try testContext.fetch(Genre.fetchRequest()).count, 0)
        addSampleMedias()
        XCTAssertEqual(try testContext.fetch(Genre.fetchRequest()).count, 6)
    }
    
    private func getTags(_ names: [String]) -> Set<Tag> {
        Set(names.map { name in self.tags.first(where: { $0.name == name })! })
    }
    
    private func getGenres(_ names: [String]) throws -> Set<Genre> {
        let fetch = Genre.fetchRequest()
        fetch.predicate = NSPredicate(format: "%K IN %@", "name", names)
        let existing = try testContext.fetch(fetch)
        XCTAssertEqual(names.count, existing.count, "Tried fetching genres \(names.joined(separator: ", ")), but received only \(existing.count) results: \(existing.map(\.name).joined(separator: ", "))")
        return Set(existing)
    }
    
    private func createMovie(title: String, watched: MovieWatchState, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [GenreDummy], rating: StarRating, year: Int, status: MediaStatus) {
        let movie = Movie(context: testContext, title: title, originalTitle: title, genres: genres, status: status, movieData: .init(rawReleaseDate: "\(year.formatted(.number.grouping(.never)))-01-01", budget: 0, revenue: 0, isAdult: false))
        movie.watched = watched
        movie.watchAgain = watchAgain
        movie.personalRating = rating
        movie.tags = getTags(tags)
        movie.notes = notes ?? ""
    }
    
    private func createShow(title: String, watched: EpisodeNumber?, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [GenreDummy], rating: StarRating, year: Int, status: MediaStatus, showType: ShowType, seasonCount: Int) {
        let show = Show(context: testContext, title: title, originalTitle: title, genres: genres, status: status, showData: .init(rawFirstAirDate: "\(year.formatted(.number.grouping(.never)))-01-01", rawLastAirDate: "\(year.formatted(.number.grouping(.never)))-01-01", numberOfEpisodes: 0, episodeRuntime: [], isInProduction: false, seasons: Array(repeating: .init(id: 0, seasonNumber: 0, episodeCount: 0, name: "", overview: nil, imagePath: nil, airDate: nil), count: seasonCount), networks: [], createdBy: []))
        show.lastWatched = watched
        show.watchAgain = watchAgain
        show.personalRating = rating
        show.tags = getTags(tags)
        show.notes = notes ?? ""
    }
    
    private func addSampleMedias() {
        createMovie(title: "Good Movie", watched: .watched, watchAgain: true,
                    tags: ["Action", "Adventure"],
                    genres: [.init(id: 1, name: "Action"), .init(id: 2, name: "Adventure")],
                    rating: .fiveStars, year: 2012, status: .released)
        createMovie(title: "Bad Movie", watched: .watched, watchAgain: false,
                    tags: ["Comedy"],
                    genres: [.init(id: 3, name: "Drama")],
                    rating: .oneAndAHalfStars, year: 1997, status: .released)
        createMovie(title: "Unwatched Movie", watched: .notWatched, watchAgain: nil,
                    tags: ["Future", "Horror"],
                    genres: [.init(id: 4, name: "Horror"), .init(id: 3, name: "Drama"), .init(id: 5, name: "Sci-Fi")],
                    rating: .noRating, year: 2023, status: .inProduction)
        createShow(title: "Good Show", watched: .init(season: 5), watchAgain: true,
                   tags: ["Comedy"],
                   genres: [.init(id: 6, name: "Comedy"), .init(id: 3, name: "Drama")],
                   rating: .fourAndAHalfStars, year: 2015, status: .released, showType: .documentary, seasonCount: 10)
        createShow(title: "Bad Show", watched: .init(season: 1, episode: 1), watchAgain: false,
                   tags: ["Future", "Adventure"],
                   genres: [.init(id: 5, name: "Sci-Fi")],
                   rating: .twoStars, year: 1990, status: .released, showType: .scripted, seasonCount: 3)
        createShow(title: "Unwatched Show", watched: nil, watchAgain: nil,
                   tags: ["Future", "Horror"],
                   genres: [.init(id: 3, name: "Drama")],
                   rating: .noRating, year: 2024, status: .planned, showType: .scripted, seasonCount: 1)
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
    
    func testFilterPersonalRating() throws {
        XCTAssertEqual(try fetch(.init(rating: nil)), .allMedias)
        XCTAssertEqual(try fetch(.init(rating: .noRating ... .noRating)), ["Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(rating: .noRating ... .fiveStars)), .allMedias)
        XCTAssertEqual(try fetch(.init(rating: .threeStars ... .fiveStars)), ["Good Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(rating: .halfStar ... .twoAndAHalfStars)), ["Bad Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(rating: .fourAndAHalfStars ... .fourAndAHalfStars)), ["Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(rating: .twoStars ... .twoStars)), ["Bad Show"].sorted())
    }
    
    func testFilterYear() throws {
        XCTAssertEqual(try fetch(.init(year: nil)), .allMedias)
        XCTAssertEqual(try fetch(.init(year: 1 ... 5000)), .allMedias)
        XCTAssertEqual(try fetch(.init(year: 2000 ... 3000)), ["Good Movie", "Unwatched Movie", "Good Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(year: 1 ... 2)), [])
        XCTAssertEqual(try fetch(.init(year: 1997 ... 1997)), ["Bad Movie"].sorted())
        XCTAssertEqual(try fetch(.init(year: 2022 ... 2023)), ["Unwatched Movie"].sorted())
    }
    
    func testFilterStatus() throws {
        // TODO: Implement
    }
    
    func testFilterShowType() throws {
        // TODO: Implement
    }
    
    func testFilterSeasons() throws {
        // TODO: Implement
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
