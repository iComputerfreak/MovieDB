//
//  TestingPlayground.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
@testable import Movie_DB
import XCTest

class TestingPlayground: XCTestCase {
    var testingUtils: TestingUtils!
    
    override func setUp() async throws {
        try await super.setUp()
        testingUtils = TestingUtils()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
    }
    
    func testPlayground() async throws {}
}
