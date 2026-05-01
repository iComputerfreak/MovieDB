// Copyright © 2022 Jonas Frey. All rights reserved.

import JFTestingUtils
import JFUtils
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
    var unifiedSearchNavBar: XCUIElement { navigationBars["Lookup"] }
    var addMediaButton: XCUIElement { libraryNavBar.buttons["add-media"] }
    var addMediaSearch: XCUIElement {
        if unifiedSearchNavBar.exists {
            unifiedSearchNavBar.searchFields.firstMatch
        } else {
            addMediaNavBar.searchFields.firstMatch
        }
    }
    var tabBar: XCUIElementQuery { tabBars.element.buttons }

    @discardableResult
    func openAddMediaEntryPoint() -> Bool {
        addMediaButton.tap()

        if unifiedSearchNavBar.waitForExistence(timeout: 5) {
            return true
        }

        XCTAssertTrue(addMediaNavBar.waitForExistence(timeout: 5))
        return false
    }
    
    func addMedia(_ query: String, name: String, checkAdded: Bool = true) {
        let usesUnifiedSearch = openAddMediaEntryPoint()
        addMediaSearch.tap()
        addMediaSearch.typeText("\(query)\n")

        let mediaCell = cells.containing(.staticText, identifier: name).firstMatch
        XCTAssertTrue(mediaCell.waitForExistence(timeout: 10))

        if usesUnifiedSearch {
            mediaCell.buttons["add-media-search-row-button"].tap()
        } else {
            mediaCell.tap()
        }

        if checkAdded {
            if usesUnifiedSearch {
                tabBar["Library"].tap()
            }

            XCTAssertTrue(
                cells.staticTexts[name]
                    .firstMatch
                    .waitForExistence(timeout: 10)
            )
        }
    }
    
    func goBack() {
        navigationBars.element.buttons.firstMatch.tap()
    }
    
    func addMatrix(checkAdded: Bool = true) {
        addMedia("The Matrix", name: "The Matrix", checkAdded: checkAdded)
    }
    
    func addBlacklist(checkAdded: Bool = true) {
        addMedia("Blacklist", name: "The Blacklist", checkAdded: checkAdded)
    }
    
    func addMatrixAndBlacklist() {
        addMatrix()
        // We need to scroll a bit to fix the add button not being hittable
        swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(self).isHittable)
        addBlacklist()
    }
}
