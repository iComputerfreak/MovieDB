//
//  UITestingHelper.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFTestingUtils
import JFUtils
@testable import Movie_DB
import XCTest

public extension XCUIApplication {
    enum LaunchArgument: String {
        case screenshots
        case prepareSamples = "prepare-samples"
        case uiTesting = "uitesting"
    }
    
    var arguments: [LaunchArgument] {
        get {
            launchArguments.map { $0.removingPrefix("--") }.compactMap(LaunchArgument.init(rawValue:))
        }
        set {
            launchArguments = newValue.map(\.rawValue).map { "--\($0)" }
        }
    }
}

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
}
