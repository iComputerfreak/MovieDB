//
//  APITests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 08.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

@testable import Movie_DB

import CoreData
import XCTest

class APITests: XCTestCase {
    // swiftlint:disable implicitly_unwrapped_optional
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    
    let api = TMDBAPI.shared
    
    var matrix: TMDBData!
    var fightClub: TMDBData!
    // swiftlint:disable:next inclusive_language
    var blacklist: TMDBData!
    var gameOfThrones: TMDBData!
    var brokenMedia: Movie!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
        matrix = TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
        fightClub = TestingUtils.load("FightClub.json", mediaType: .movie, into: testContext)
        blacklist = TestingUtils.load("Blacklist.json", mediaType: .show, into: testContext)
        gameOfThrones = TestingUtils.load("GameOfThrones.json", mediaType: .show, into: testContext)
        brokenMedia = {
            let movie = Movie(
                context: testContext,
                tmdbData: TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
            )
            movie.tmdbID = -1
            return movie
        }()
    }
    
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
        matrix = nil
        fightClub = nil
        blacklist = nil
        gameOfThrones = nil
        brokenMedia = nil
    }
    
    func testFetchTMDBData() async throws {
        let result = try await api.media(for: 603, type: .movie, context: testContext)
        assertMediaMatches(result, .init(tmdbID: 603, type: .movie, title: "The Matrix"))
        XCTAssertNotNil((result as? Movie)?.releaseDate)
    }
    
    func testAPISuccess() async throws {
        let mediaObjects = [
            DummyMedia(tmdbID: 550, type: .movie, title: "Fight Club"),
            DummyMedia(tmdbID: 603, type: .movie, title: "The Matrix"),
            DummyMedia(tmdbID: 1399, type: .show, title: "Game of Thrones"),
            DummyMedia(tmdbID: 46952, type: .show, title: "The Blacklist"),
        ]
        
        for dummy in mediaObjects {
            let result = try await api.media(for: dummy.tmdbID, type: dummy.type, context: testContext)
            assertMediaMatches(result, dummy)
            
            // Modify the title to check, if the update function correctly restores it
            result.title = "None"
            // Should not throw
            try await api.updateMedia(result, context: testContext)
            assertMediaMatches(result, dummy)
        }
    }
    
    func testAPIFailure() async {
        await assertAPIErrorThrown {
            _ = try await api.media(for: -1, type: .movie, context: testContext)
        }
        await assertAPIErrorThrown {
            try await api.updateMedia(brokenMedia, context: testContext)
        }
    }
    
    func testSearch() async throws {
        let (results, totalPages) = try await api.searchMedia("matrix", includeAdult: true, to: 1)
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertGreaterThanOrEqual(totalPages, 1)
        XCTAssertEqual(results.first(where: { $0.id == 603 && $0.mediaType == .movie })?.title, "The Matrix")
        
        let (results2, _) = try await api.searchMedia(
            "ThisIsSomeReallyLongNameIHopeWillResultInZeroResults",
            includeAdult: true
        )
        XCTAssertEqual(results2.count, 0)
    }

    private func assertAPIErrorThrown<T>(_ operation: () async throws -> T) async {
        do {
            _ = try await operation()
            XCTFail("Expected TMDBAPI.APIError to be thrown.")
        } catch is TMDBAPI.APIError {
            return
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
}

struct DummyMedia {
    static let broken = Self(tmdbID: -1, type: .movie, title: "")
    
    var tmdbID: Int
    var type: MediaType
    var title: String
}

func assertMediaMatches(_ media: Media?, _ dummy: DummyMedia) {
    XCTAssertNotNil(media)
    XCTAssertEqual(media?.type, dummy.type)
    XCTAssertEqual(media?.tmdbID, dummy.tmdbID)
    XCTAssertEqual(media?.title, dummy.title)
}
