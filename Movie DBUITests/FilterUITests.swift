//
//  FilterUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFTestingUtils
import XCTest

class FilterUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.arguments = [.uiTesting, .prepareSamples]
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
    }
    
    func configureFilter(_ key: String, configureValue: () -> Void) {
        // We start at the library view
        let navBar = app.navigationBars["Library"]
        navBar.buttons["More"].forceTap()
        app.buttons["Filter"].tap()
        // Change the desired filter setting
        app.cells.staticTexts[key].tap()
        configureValue()
        app.buttons["Apply"].tap()
    }
    
    func testFilterMediaType() {
        app.launch()
        
        configureFilter("Media Type") {
            app.buttons["Movie"].tap()
        }
        
        app.wait(1)
        
        XCTAssert(app.cells.staticTexts["The Matrix"].exists)
        XCTAssert(app.staticTexts["1 object"].exists)
    }
    
    // TODO: Test other filter settings
}
