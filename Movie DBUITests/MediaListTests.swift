//
//  MediaListTests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 31.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import XCTest

class MediaListTests: XCTestCase {
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
    
    func testSorting() {
        app.launch()
        
        app.tabBar["Lists"].tap()
        app.cells.staticTexts["Watchlist"].tap()
        
        // To reset the direction, we first have to switch to something else first
        changeSort(to: "Name")
        
        changeSort(to: "Release Date")
        assertLokiBeforeDoctorWho()
        changeSort(to: "Release Date")
        assertDoctorWhoBeforeLoki()
        
        changeSort(to: "Name")
        assertDoctorWhoBeforeLoki()
        changeSort(to: "Name")
        assertLokiBeforeDoctorWho()
        
        changeSort(to: "Created")
        assertDoctorWhoBeforeLoki()
        changeSort(to: "Created")
        assertLokiBeforeDoctorWho()
        
        changeSort(to: "Rating")
        assertLokiBeforeDoctorWho() // Only because of the title; rating is equal
        changeSort(to: "Rating")
        assertDoctorWhoBeforeLoki()
    }
    
    func testSearch() {
        app.launch()
        
        app.tabBar["Lists"].tap()
        app.cells.staticTexts["Watchlist"].tap()
        // TODO: Write test when search is implemented
    }
    
    private func assertLokiBeforeDoctorWho() {
        XCTAssert(app.cells.staticTexts["Loki"].frame.minY < app.cells.staticTexts["Doctor Who"].frame.minY)
    }
    
    private func assertDoctorWhoBeforeLoki() {
        XCTAssert(app.cells.staticTexts["Doctor Who"].frame.minY < app.cells.staticTexts["Loki"].frame.minY)
    }
    
    private func changeSort(to order: String) {
        app.navigationBars.buttons["Sort"].images.firstMatch.tap()
        app.buttons[order].tap()
    }
}
