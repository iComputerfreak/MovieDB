//
//  TMDBSearchTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class TMDBSearchTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testSearchResultsDecoding() {
        _ = TestingUtils.load("searchResults.json", as: SearchResult.self)
    }
}
