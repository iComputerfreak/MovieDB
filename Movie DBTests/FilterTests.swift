//
//  FilterTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
@testable import Movie_DB
import XCTest

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
        tags = [
            Tag(name: "Action", context: testContext),
            Tag(name: "Adventure", context: testContext),
            Tag(name: "Horror", context: testContext),
            Tag(name: "Future", context: testContext),
            Tag(name: "Comedy", context: testContext),
        ]
        // Add sample medias to filter
        XCTAssertEqual(try testContext.fetch(Genre.fetchRequest()).count, 0)
        addSampleMedias()
        XCTAssertEqual(try testContext.fetch(Genre.fetchRequest()).count, 6)
    }
    
    private func getTags(_ names: [String]) -> Set<Tag> {
        Set(names.map { name in self.tags.first(where: \.name, equals: name)! })
    }
    
    private func getGenres(_ names: [String]) throws -> Set<Genre> {
        let fetch = Genre.fetchRequest()
        fetch.predicate = NSPredicate(format: "%K IN %@", "name", names)
        let existing = try testContext.fetch(fetch)
        XCTAssertEqual(names.count, existing.count, "Tried fetching genres \(names.joined(separator: ", ")), but received only \(existing.count) results: \(existing.map(\.name).joined(separator: ", "))")
        return Set(existing)
    }
    
    private func createMovie(title: String, watched: MovieWatchState, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [GenreDummy], rating: StarRating, year: Int, status: MediaStatus) {
        let movie = Movie(context: testContext, title: title, originalTitle: title, genres: genres, status: status, movieData: .init(rawReleaseDate: "\(year.formatted(.number.grouping(.never)))-01-01", budget: 0, revenue: 0, isAdult: false, directors: ["John Doe"]))
        movie.watched = watched
        movie.watchAgain = watchAgain
        movie.personalRating = rating
        movie.tags = getTags(tags)
        movie.notes = notes ?? ""
    }
    
    private func createShow(title: String, watched: ShowWatchState?, watchAgain: Bool?, tags: [String], notes: String? = nil, genres: [GenreDummy], rating: StarRating, year: Int, status: MediaStatus, showType: ShowType, seasonCount: Int) {
        let show = Show(context: testContext, title: title, originalTitle: title, genres: genres, status: status, showData: .init(rawFirstAirDate: "\(year.formatted(.number.grouping(.never)))-01-01", rawLastAirDate: "\(year.formatted(.number.grouping(.never)))-01-01", numberOfSeasons: seasonCount, numberOfEpisodes: 0, episodeRuntime: [], isInProduction: false, seasons: Array(repeating: .init(id: 0, seasonNumber: 0, episodeCount: 0, name: "", overview: nil, imagePath: nil, airDate: nil), count: seasonCount), showType: showType, networks: [], createdBy: []))
        show.watched = watched
        show.watchAgain = watchAgain
        show.personalRating = rating
        show.tags = getTags(tags)
        show.notes = notes ?? ""
    }
    
    private func addSampleMedias() {
        createMovie(title: "Good Movie", watched: .watched, watchAgain: true,
                    tags: ["Action", "Adventure"],
                    genres: [.init(id: 1, name: "Action"), .init(id: 2, name: "Adventure")],
                    rating: .fiveStars, year: 2012, status: .ended)
        createMovie(title: "Bad Movie", watched: .watched, watchAgain: false,
                    tags: ["Comedy"],
                    genres: [.init(id: 3, name: "Drama")],
                    rating: .oneAndAHalfStars, year: 1997, status: .released)
        createMovie(title: "Unwatched Movie", watched: .notWatched, watchAgain: nil,
                    tags: ["Future", "Horror"],
                    genres: [.init(id: 4, name: "Horror"), .init(id: 3, name: "Drama"), .init(id: 5, name: "Sci-Fi")],
                    rating: .noRating, year: 2023, status: .inProduction)
        createShow(title: "Good Show", watched: .season(5), watchAgain: true,
                   tags: ["Comedy"],
                   genres: [.init(id: 6, name: "Comedy"), .init(id: 3, name: "Drama")],
                   rating: .fourAndAHalfStars, year: 2015, status: .released, showType: .documentary, seasonCount: 10)
        createShow(title: "Bad Show", watched: .notWatched, watchAgain: false,
                   tags: ["Future", "Adventure"],
                   genres: [.init(id: 5, name: "Sci-Fi")],
                   rating: .twoStars, year: 1990, status: .canceled, showType: .scripted, seasonCount: 3)
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
        XCTAssertEqual(try fetch(.init(with: testContext, watched: .watched)), ["Good Movie", "Bad Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, watched: .notWatched)), ["Unwatched Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, watched: nil)), .allMedias)
    }
    
    func testFilterWatchAgain() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, watchAgain: true)), ["Good Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, watchAgain: false)), ["Bad Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, watchAgain: nil)), .allMedias)
    }
    
    func testFilterTags() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Action"]))), ["Good Movie"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Adventure"]))), ["Good Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Horror"]))), ["Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Future"]))), ["Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Comedy"]))), ["Bad Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: [])), .allMedias)
        
        // Multiple tags (should return medias that contain any of the filtered tags)
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Future", "Horror"]))), ["Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, tags: getTags(["Comedy", "Action"]))), ["Good Movie", "Bad Movie", "Good Show"].sorted())
    }
    
    func testFilterMediaType() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, mediaType: .movie)), ["Good Movie", "Bad Movie", "Unwatched Movie"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, mediaType: .show)), ["Good Show", "Bad Show", "Unwatched Show"].sorted())
    }
    
    func testFilterGenres() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, genres: getGenres(["Action"]))), ["Good Movie"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, genres: getGenres(["Drama"]))), ["Bad Movie", "Unwatched Movie", "Good Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, genres: getGenres(["Sci-Fi"]))), ["Unwatched Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, genres: getGenres([]))), .allMedias)
    }
    
    func testFilterPersonalRating() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, rating: nil)), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .noRating ... .noRating)), ["Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .noRating ... .fiveStars)), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .threeStars ... .fiveStars)), ["Good Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .halfStar ... .twoAndAHalfStars)), ["Bad Movie", "Bad Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .fourAndAHalfStars ... .fourAndAHalfStars)), ["Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, rating: .twoStars ... .twoStars)), ["Bad Show"].sorted())
    }
    
    func testFilterYear() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, year: nil)), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, year: 1...5000)), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, year: 2000...3000)), ["Good Movie", "Unwatched Movie", "Good Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, year: 1...2)), [])
        XCTAssertEqual(try fetch(.init(with: testContext, year: 1997...1997)), ["Bad Movie"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, year: 2022...2023)), ["Unwatched Movie"].sorted())
    }
    
    func testFilterStatus() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, statuses: [])), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, statuses: [.released, .ended, .canceled, .planned, .inProduction])), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, statuses: [.released])), ["Bad Movie", "Good Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, statuses: [.canceled])), ["Bad Show"])
        XCTAssertEqual(try fetch(.init(with: testContext, statuses: [.ended, .planned])), ["Good Movie", "Unwatched Show"].sorted())
    }
    
    func testFilterShowType() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, showTypes: [])), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, showTypes: [.scripted, .documentary])), ["Good Movie", "Bad Movie", "Unwatched Movie", "Good Show", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, showTypes: [.scripted])), ["Good Movie", "Bad Movie", "Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, showTypes: [.documentary])), ["Good Movie", "Bad Movie", "Unwatched Movie", "Good Show"].sorted())
    }
    
    func testFilterSeasons() throws {
        XCTAssertEqual(try fetch(.init(with: testContext, numberOfSeasons: 0...100)), .allMedias)
        XCTAssertEqual(try fetch(.init(with: testContext, numberOfSeasons: 0...1)), ["Good Movie", "Bad Movie", "Unwatched Movie", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, numberOfSeasons: 0...3)), ["Good Movie", "Bad Movie", "Unwatched Movie", "Bad Show", "Unwatched Show"].sorted())
        XCTAssertEqual(try fetch(.init(with: testContext, numberOfSeasons: 5...10)), ["Good Movie", "Bad Movie", "Unwatched Movie", "Good Show"].sorted())
    }
    
    private func fetch(_ filter: FilterSetting) throws -> [String] {
        let fetch = Media.fetchRequest()
        fetch.predicate = filter.buildPredicate()
        return try testContext.fetch(fetch).map(\.title).sorted()
    }
    
    func testSaveContext() throws {
        try testContext.save()
    }
    
    func testSaveChildContext() throws {
        try testContext.newBackgroundContext().save()
    }
}

extension [String] {
    static let allMedias = ["Good Movie", "Bad Movie", "Unwatched Movie", "Good Show", "Bad Show", "Unwatched Show"].sorted()
}
