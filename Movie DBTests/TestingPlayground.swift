// Copyright © 2022 Jonas Frey. All rights reserved.

import CoreData
@testable import Movie_DB
import XCTest

final class TestingPlayground: XCTestCase {
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }

    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
    }

    override func tearDown() {
        testingUtils = nil
        super.tearDown()
    }

    func testShowWatchStateInitFromSeasonAndEpisode() {
        XCTAssertNil(ShowWatchState(season: -1, episode: nil))
        XCTAssertEqual(ShowWatchState(season: 0, episode: nil), .notWatched)
        XCTAssertEqual(ShowWatchState(season: 2, episode: nil), .season(2))
        XCTAssertEqual(ShowWatchState(season: 2, episode: 0), .season(2))
        XCTAssertEqual(ShowWatchState(season: 2, episode: 5), .episode(season: 2, episode: 5))
    }

    func testShowWatchStateRawValueRoundTrip() {
        let states: [ShowWatchState] = [
            .notWatched,
            .season(3),
            .episode(season: 2, episode: 4),
        ]

        for state in states {
            XCTAssertEqual(ShowWatchState(rawValue: state.rawValue), state)
        }

        XCTAssertNil(ShowWatchState(rawValue: "episode,1"))
        XCTAssertNil(ShowWatchState(rawValue: "season"))
        XCTAssertNil(ShowWatchState(rawValue: "invalid"))
    }

    func testShowWatchStateComparable() {
        XCTAssertLessThan(ShowWatchState.notWatched, .season(1))
        XCTAssertLessThan(ShowWatchState.notWatched, .episode(season: 1, episode: 1))
        XCTAssertLessThan(ShowWatchState.episode(season: 1, episode: 1), .season(1))
        XCTAssertLessThan(ShowWatchState.season(1), .season(2))
        XCTAssertLessThan(ShowWatchState.episode(season: 1, episode: 5), .episode(season: 2, episode: 1))
        XCTAssertGreaterThan(ShowWatchState.season(2), .episode(season: 1, episode: 10))
    }

    func testShowWatchStatePredicatesClassifyShows() throws {
        testContext.reset()

        let notWatched = Show(context: testContext, id: 1, title: "Not Watched")
        notWatched.numberOfSeasons = 3
        notWatched.watched = .notWatched

        let watchedSeason = Show(context: testContext, id: 2, title: "Watched Season")
        watchedSeason.numberOfSeasons = 4
        watchedSeason.watched = .season(2)

        let watchedEpisode = Show(context: testContext, id: 3, title: "Watched Episode")
        watchedEpisode.numberOfSeasons = 4
        watchedEpisode.watched = .episode(season: 2, episode: 3)

        let watchedAll = Show(context: testContext, id: 4, title: "Watched All")
        watchedAll.numberOfSeasons = 4
        watchedAll.watched = .season(4)

        let unknown = Show(context: testContext, id: 5, title: "Unknown")
        unknown.numberOfSeasons = 4
        unknown.watched = nil

        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsNotWatchedPredicate), ["Not Watched"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedAnyPredicate), ["Watched All", "Watched Episode", "Watched Season"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedEpisodePredicate), ["Watched Episode"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedSeasonPredicate), ["Watched All", "Watched Season"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedUnknownPredicate), ["Unknown"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedPartiallyPredicate), ["Watched Episode", "Watched Season"])
        XCTAssertEqual(try fetchShowTitles(using: ShowWatchState.showsWatchedAllSeasonsPredicate), ["Watched All"])
    }

    func testSortingOrderSortDescriptorsSortExpectedFields() throws {
        testContext.reset()

        let oldest = Movie(context: testContext, id: 1, title: "Beta")
        oldest.creationDate = Date(timeIntervalSince1970: 10)

        let newestA = Movie(context: testContext, id: 2, title: "Alpha")
        newestA.creationDate = Date(timeIntervalSince1970: 20)

        let newestB = Movie(context: testContext, id: 3, title: "Gamma")
        newestB.creationDate = Date(timeIntervalSince1970: 20)

        XCTAssertEqual(try fetchMovieTitles(sortedBy: .name, direction: .ascending), ["Alpha", "Beta", "Gamma"])
        XCTAssertEqual(try fetchMovieTitles(sortedBy: .created, direction: .descending), ["Gamma", "Alpha", "Beta"])
        XCTAssertEqual(try fetchMovieTitles(sortedBy: .created, direction: .ascending), ["Beta", "Alpha", "Gamma"])
    }

    func testSortingDirectionToggle() {
        var direction = SortingDirection.ascending
        direction.toggle()
        XCTAssertEqual(direction, .descending)
        direction.toggle()
        XCTAssertEqual(direction, .ascending)
    }

    func testLastNameComparatorUsesLastNameThenFirstName() {
        let comparator = LastNameComparator(order: .forward)

        XCTAssertEqual(comparator.compare("Jane Doe", "John Smith"), .orderedAscending)
        XCTAssertEqual(comparator.compare("John Smith", "Adam Smith"), .orderedDescending)
        XCTAssertEqual(comparator.compare("", "Jane Doe"), .orderedDescending)
    }

    func testUtilsBoundsReflectExistingLibraryData() {
        testContext.reset()

        let movie = Movie(context: testContext, id: 1, title: "Movie")
        movie.releaseDate = Utils.tmdbUTCDateFormatter.date(from: "1999-03-30")

        let olderShow = Show(context: testContext, id: 2, title: "Older Show")
        olderShow.firstAirDate = Utils.tmdbUTCDateFormatter.date(from: "2005-01-01")
        olderShow.numberOfSeasons = 7

        let newerShow = Show(context: testContext, id: 3, title: "Newer Show")
        newerShow.firstAirDate = Utils.tmdbUTCDateFormatter.date(from: "2015-01-01")
        newerShow.numberOfSeasons = 2

        XCTAssertEqual(Utils.yearBounds(context: testContext), 1999...2015)
        XCTAssertEqual(Utils.numberOfSeasonsBounds(context: testContext), 2...7)
    }

    private func fetchShowTitles(using predicate: NSPredicate) throws -> [String] {
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try testContext.fetch(fetchRequest).map(\.title)
    }

    private func fetchMovieTitles(sortedBy order: SortingOrder, direction: SortingDirection) throws -> [String] {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = order.createSortDescriptors(with: direction)
        return try testContext.fetch(fetchRequest).map(\.title)
    }
}
