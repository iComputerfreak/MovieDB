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
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testAPI() {
        let api = TMDBAPI.shared
        var expectations = [XCTestExpectation]()
        var genres = Set<Genre>()
        
        for type in [MediaType.show, MediaType.movie] {
            for id in stride(from: 0, to: 10000, by: 200) {
                let expectation = XCTestExpectation(description: "Get genres of ID \(id)")
                expectations.append(expectation)
                /*api.fetchMedia(id: id, type: type) { (data) in
                    guard let myGenres = data?.genres else {
                        print("No data for ID \(id)")
                        return
                    }
                    let newGenres = Set(myGenres).subtracting(genres)
                    if !newGenres.isEmpty {
                        for genre in newGenres {
                            print("New Genre: \(genre.name) (\(genre.id))")
                        }
                    }
                    genres = genres.union(myGenres)
                    expectation.fulfill()
                }*/
                sleep(1)
            }
            print("Finished loading genres for \(type.rawValue)")
        }
        
        wait(for: expectations, timeout: 60000)
        print("Finished loading all Genres")
    }
}
