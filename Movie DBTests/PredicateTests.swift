//
//  PredicateTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 13.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
@testable import Movie_DB
import XCTest

class PredicateTests: XCTestCase {
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
        // Remove default medias and tags
        testContext.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        testContext.reset()
    }
    
    func testNewSeasonsAvailablePredicate() throws {
        let predicateCompletelyWatched = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "type = %@", MediaType.show.rawValue),
            NSPredicate(format: "lastSeasonWatched > 0 AND lastSeasonWatched < numberOfSeasons"),
        ])
        
        PlaceholderData.context.reset()
        
        let matchingMedia1 = PlaceholderData.createShow()
        matchingMedia1.title = "Media 1"
        matchingMedia1.numberOfSeasons = 11
        matchingMedia1.watched = .season(11)
        
        let matchingMedia2 = PlaceholderData.createShow()
        matchingMedia2.title = "Media 2"
        matchingMedia2.numberOfSeasons = 1
        matchingMedia2.watched = .season(11)
        
        let nonMatchingMedia = PlaceholderData.createShow()
        nonMatchingMedia.title = "Media 3"
        nonMatchingMedia.numberOfSeasons = 11
        nonMatchingMedia.watched = .season(1)
        
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = predicateCompletelyWatched
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let results = try PlaceholderData.context.fetch(fetchRequest)
        
        XCTAssertEqual(results.map(\.title), [matchingMedia1.title, matchingMedia2.title])
    }
    
    func testAnyPredicate() throws {
        PlaceholderData.context.reset()
        
        let show = PlaceholderData.createShow()
        show.watched = .season(1)
        show.numberOfSeasons = 2
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "type = %@", MediaType.show.rawValue),
            ShowWatchState.showsWatchedAnyPredicate,
            NSPredicate(format: "lastSeasonWatched < numberOfSeasons"),
        ])
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        fetchRequest.predicate = predicate
        let results = try PlaceholderData.context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)
        print(results)
    }
}
