//
//  JFUtilsTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 11.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

@testable import Movie_DB
import XCTest

class JFUtilsTests: XCTestCase {
    func testLocale() {
        XCTAssertEqual(Utils.languageString(for: "en", locale: Locale(identifier: "en")), "English")
        XCTAssertEqual(Utils.languageString(for: "en", locale: Locale(identifier: "de")), "Englisch")
    }
}
