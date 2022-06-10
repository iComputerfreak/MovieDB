//
//  FilterUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class FilterUITests: XCTestCase {
    var app: XCUIApplication! = nil

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
    }
    
    func addSampleMedias() {
        app.addMatrix()
        app.swipeUp()
        app.addBlacklist()
        app.swipeUp()
        app.addMedia("Fight Club", name: "Fight Club", type: .movie)
        app.swipeUp()
        app.addMedia("Stranger Things", name: "Stranger Things", type: .show)
    }
    
    func configureFilter(_ key: String, configureValue: () -> Void) {
        // We start at the library view
        app.buttons["More"].tap()
        app.buttons["Filter"].tap()
        // Change the desired filter setting
        app.cells[key].tap()
        configureValue()
        app.buttons["Apply"].tap()
    }
    
    func testFilterMeidaType() {
        app.launch()
        
        addSampleMedias()
        
        configureFilter("Media Type") {
            app.cells["Movie"].tap()
            app.goBack()
        }
        
        app.wait(1)
        
        XCTAssertEqual(app.cells.count, 2)
        XCTAssert(app.cells.first(hasPrefix: "Fight Club").exists)
        XCTAssert(app.cells.first(hasPrefix: "The Matrix").exists)
        XCTAssert(app.staticTexts["2 objects"].exists)
    }
        
    func goToTags(mediaName: String, app: XCUIApplication) {
        app.cells.first(hasPrefix: mediaName).tap()
        app.navigationBars[mediaName].buttons["Edit"].wait().tap()
        app.cells.first(hasPrefix: "Tags").staticTexts.firstMatch.wait().tap()
    }
    
    func addTag(_ name: String, _ app: XCUIApplication) {
        let navBar = app.navigationBars["Tags"]
        navBar.buttons["Add"].tap()
        app.textFields.element.typeText(name)
        app.alerts.buttons["Add"].tap()
        // Check if it worked
        XCTAssertTrue(app.tables.cells[name].wait().exists)
    }
}
