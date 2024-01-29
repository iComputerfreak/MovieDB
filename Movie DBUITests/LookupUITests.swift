//
//  LookupUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 29.01.24.
//  Copyright © 2024 Jonas Frey. All rights reserved.
//

import XCTest

class LookupUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.arguments = [.uiTesting]
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
    }
    
    func testAddLookupMedia() throws {
        app.launch()
        
        app.tabBar["Lookup"].tap()
        app.textFields.firstMatch.tap()
        app.typeText("The good the bad and the ugly")
        app.wait(1)
        app.cells.firstMatch.tap()
        app.navigationBars.buttons["Add"].tap()
        // swiftformat:disable:next isEmpty
        XCTAssert(app.alerts.count == 0)
    }
}
