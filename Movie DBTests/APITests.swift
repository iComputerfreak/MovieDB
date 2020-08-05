//
//  APITests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 08.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class APITests: XCTestCase {
    
    let api = TMDBAPI.shared
    
    let matrix: TMDBMovieData = TestingUtils.load("Matrix.json")
    let fightClub: TMDBMovieData = TestingUtils.load("FightClub.json")
    let blacklist: TMDBShowData = TestingUtils.load("Blacklist.json")
    let gameOfThrones: TMDBShowData = TestingUtils.load("GameOfThrones.json")
    
    let emptyMedia = Movie()
    let brokenMedia: Movie = {
        let movie = Movie()
        movie.tmdbData = TestingUtils.load("Matrix.json")
        movie.tmdbData?.id = -1
        return movie
    }()
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testAPISuccess() throws {
        let mediaObjects = [
            DummyMedia(tmdbID: 550, type: .movie, title: "Fight Club"),
            DummyMedia(tmdbID: 603, type: .movie, title: "The Matrix"),
            DummyMedia(tmdbID: 1399, type: .show, title: "Game of Thrones"),
            DummyMedia(tmdbID: 46952, type: .show, title: "The Blacklist")
        ]
        
        for dummy in mediaObjects {
            let result = try api.fetchMedia(id: dummy.tmdbID, type: dummy.type)
            assertMediaMatches(result, dummy)
            
            // Modify the title to check, if the update function correctly restores it
            result.tmdbData?.title = "None"
            let promise = XCTestExpectation()
            XCTAssertNoThrow(try api.updateMedia(result, completion: { promise.fulfill() }))
            wait(for: [promise], timeout: 5)
            assertMediaMatches(result, dummy)
        }
    }
    
    func testAPIFailure() {
        XCTAssertThrowsError(try api.fetchMedia(id: -1, type: .movie))
        XCTAssertThrowsError(try api.updateMedia(emptyMedia))
        XCTAssertThrowsError(try api.updateMedia(brokenMedia))
    }
    
    func testSearch() throws {
        let results = try api.searchMedia("matrix", includeAdult: true)
        XCTAssertGreaterThan(results.count, 0)
        
        let results2 = try api.searchMedia("ThisIsSomeReallyLongNameIHopeWillResultInZeroResults")
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
    XCTAssertNotNil(media?.tmdbData)
    XCTAssertEqual(media?.tmdbData?.id, dummy.tmdbID)
    XCTAssertEqual(media?.tmdbData?.title, dummy.title)
}
