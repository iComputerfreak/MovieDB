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
        let predicateNotCompletelyWatched = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "type = %@", MediaType.show.rawValue),
            NSPredicate(format: "lastSeasonWatched > 0 AND lastSeasonWatched < numberOfSeasons"),
        ])
        
        let media1 = PlaceholderData.createShow(in: testingUtils.context)
        media1.title = "Media 1"
        media1.numberOfSeasons = 11
        media1.watched = .season(11)
        
        let media2 = PlaceholderData.createShow(in: testingUtils.context)
        media2.title = "Media 2"
        media2.numberOfSeasons = 1
        media2.watched = .season(11)
        
        let media3 = PlaceholderData.createShow(in: testingUtils.context)
        media3.title = "Media 3"
        media3.numberOfSeasons = 11
        media3.watched = .season(1)
        
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = predicateNotCompletelyWatched
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let results = try testingUtils.context.fetch(fetchRequest)
        
        XCTAssertEqual(results.map(\.title), [media3.title])
    }
    
    func testAnyPredicate() throws {
        let show = PlaceholderData.createShow(in: testingUtils.context)
        show.watched = .season(1)
        show.numberOfSeasons = 2
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "type = %@", MediaType.show.rawValue),
            ShowWatchState.showsWatchedAnyPredicate,
            NSPredicate(format: "lastSeasonWatched < numberOfSeasons"),
        ])
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        fetchRequest.predicate = predicate
        let results = try testingUtils.context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)
        print(results)
    }
}
