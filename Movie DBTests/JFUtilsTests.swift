// Copyright © 2019 Jonas Frey. All rights reserved.

import Foundation

@testable import Movie_DB
import XCTest

class JFUtilsTests: XCTestCase {
    func testLocale() {
        XCTAssertEqual(Utils.languageString(for: "en", locale: Locale(identifier: "en")), "English")
        XCTAssertEqual(Utils.languageString(for: "en", locale: Locale(identifier: "de")), "Englisch")
    }
}
