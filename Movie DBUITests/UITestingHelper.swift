//
//  UITestingHelper.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var libraryNavBar: XCUIElement { navigationBars["Library"] }
    var addMediaNavBar: XCUIElement { navigationBars["Add Media"] }
    var addMediaButton: XCUIElement { libraryNavBar.buttons["add-media"] }
    var addMediaSearch: XCUIElement { addMediaNavBar.searchFields.firstMatch }
    var tabBar: XCUIElementQuery { tabBars.element.buttons }
    
    func addMedia(_ query: String, name: String, type: MediaType, checkAdded: Bool = true) {
        addMediaButton.tap()
        addMediaSearch.tap()
        addMediaSearch.typeText("\(query)\n")
        cells.staticTexts[name]
            .firstMatch
            .wait()
            .tap()
        if checkAdded {
            XCTAssertTrue(cells.staticTexts[name]
                .firstMatch
                .waitForExistence(timeout: 10))
        }
    }
    
    func goBack() {
        navigationBars.element.buttons.firstMatch.tap()
    }
    
    func addMatrix(checkAdded: Bool = true) {
        addMedia("The Matrix", name: "The Matrix", type: .movie, checkAdded: checkAdded)
    }
    
    func addBlacklist(checkAdded: Bool = true) {
        addMedia("Blacklist", name: "The Blacklist", type: .show, checkAdded: checkAdded)
    }
    
    func addMatrixAndBlacklist() {
        addMatrix()
        // We need to scroll a bit to fix the add button not being hittable
        swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(self).isHittable)
        addBlacklist()
    }
    
    func wait(_ timeout: TimeInterval = 1) {
        XCTAssertFalse(wait(for: .runningBackground, timeout: timeout))
    }
}

extension XCUIElement {
    @discardableResult
    func wait() -> XCUIElement {
        if !exists {
            XCTAssertTrue(waitForExistence(timeout: 5))
        }
        return self
    }
    
    func waitForHittable(_ app: XCUIApplication, timeout: TimeInterval = 5.0) -> XCUIElement {
        var waited: TimeInterval = 0
        while waited < timeout {
            guard !isHittable else {
                return self
            }
            // We should not actually go into background. We just use this function to wait
            XCTAssertFalse(app.wait(for: .runningBackground, timeout: 0.5))
            waited += 0.5
        }
        return self
    }
}

enum MediaType {
    case movie, show
}

extension XCUIElementQuery {
    func first(where key: String = "label", hasPrefix prefix: String) -> XCUIElement {
        matching(NSPredicate(format: "%K BEGINSWITH %@", key, prefix)).firstMatch
    }
}
