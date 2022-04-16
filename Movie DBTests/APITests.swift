//
//  APITests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 08.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB
import CoreData

class APITests: XCTestCase {
    
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    
    let api = TMDBAPI.shared
    
    var matrix: TMDBData!
    var fightClub: TMDBData!
    var blacklist: TMDBData!
    var gameOfThrones: TMDBData!
    var brokenMedia: Movie!
    
    override func setUp() {
        testingUtils = TestingUtils()
        matrix = TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
        fightClub = TestingUtils.load("FightClub.json", mediaType: .movie, into: testContext)
        blacklist = TestingUtils.load("Blacklist.json", mediaType: .show, into: testContext)
        gameOfThrones = TestingUtils.load("GameOfThrones.json", mediaType: .show, into: testContext)
        brokenMedia = {
            let movie = Movie(context: testContext, tmdbData: TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext))
            movie.tmdbID = -1
            return movie
        }()
    }
    
    func testSaveContext() throws {
        try testContext.save()
    }
    
    func testSaveChildContext() throws {
        try testContext.newBackgroundContext().save()
    }
    
    func disabled_testFetchTMDBData() throws {
        // TODO: See testAPISuccess
        let result = try api.fetchMedia(id: 603, type: .movie, context: testContext)
        print(result)
    }
    
    func disabled_testAPISuccess() throws {
        let mediaObjects = [
            DummyMedia(tmdbID: 550, type: .movie, title: "Fight Club"),
            DummyMedia(tmdbID: 603, type: .movie, title: "The Matrix"),
            DummyMedia(tmdbID: 1399, type: .show, title: "Game of Thrones"),
            DummyMedia(tmdbID: 46952, type: .show, title: "The Blacklist")
        ]
        
        for dummy in mediaObjects {
            // TODO: context.save() does not return!
            let result = try api.fetchMedia(id: dummy.tmdbID, type: dummy.type, context: testContext)
            assertMediaMatches(result, dummy)
            
            // Modify the title to check, if the update function correctly restores it
            result.title = "None"
            let promise = XCTestExpectation()
            XCTAssertNoThrow(api.updateMedia(result, context: testContext, completion: { _ in promise.fulfill() }))
            wait(for: [promise], timeout: 5)
            assertMediaMatches(result, dummy)
        }
    }
    
    func testAPIFailure() {
        XCTAssertThrowsError(try api.fetchMedia(id: -1, type: .movie, context: testContext))
        let promise = XCTestExpectation()
        api.updateMedia(brokenMedia, context: testContext, completion: { error in
            XCTAssertNotNil(error)
            promise.fulfill()
        })
        wait(for: [promise], timeout: 5)
    }
    
    func testSearch() throws {
        let promise = XCTestExpectation()
        var searchResults: [TMDBSearchResult]? = nil
        api.searchMedia("matrix", includeAdult: true, completion: { results, _ in
            searchResults = results
            promise.fulfill()
        })
        wait(for: [promise], timeout: 5)
        let results = try XCTUnwrap(searchResults)
        XCTAssertGreaterThan(results.count, 0)
        
        let promise2 = XCTestExpectation()
        var searchResults2: [TMDBSearchResult]? = nil
        api.searchMedia("ThisIsSomeReallyLongNameIHopeWillResultInZeroResults", includeAdult: true, completion: { results, _ in
            searchResults2 = results
            promise2.fulfill()
        })
        wait(for: [promise2], timeout: 5)
        let results2 = try XCTUnwrap(searchResults2)
        XCTAssertEqual(results2.count, 0)
    }
}

struct DummyMedia {
    var tmdbID: Int
    var type: MediaType
    var title: String
    
    static let broken = DummyMedia(tmdbID: -1, type: .movie, title: "")
}

func assertMediaMatches(_ media: Media?, _ dummy: DummyMedia) {
    XCTAssertNotNil(media)
    XCTAssertEqual(media?.type, dummy.type)
    XCTAssertEqual(media?.tmdbID, dummy.tmdbID)
    XCTAssertEqual(media?.title, dummy.title)
}
