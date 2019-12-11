//
//  JFUtilsTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 11.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

import XCTest
@testable import Movie_DB

class JFUtilsTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testLocale() {
        XCTAssertEqual(JFUtils.languageString(for: "en", locale: Locale(identifier: "en")), "English")
        XCTAssertEqual(JFUtils.regionString(for: "US", locale: Locale(identifier: "en")), "United States")
        XCTAssertEqual(JFUtils.languageString(for: "en", locale: Locale(identifier: "de")), "Englisch")
        XCTAssertEqual(JFUtils.regionString(for: "US", locale: Locale(identifier: "de")), "Vereinigte Staaten")
    }
}
