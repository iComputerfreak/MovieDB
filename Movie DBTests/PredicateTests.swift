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

// swiftlint:disable:next type_body_length
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
        
        let media1 = PlaceholderData.createStaticShow(in: testingUtils.context)
        media1.title = "Media 1"
        media1.numberOfSeasons = 11
        media1.watched = .season(11)
        
        let media2 = PlaceholderData.createStaticShow(in: testingUtils.context)
        media2.title = "Media 2"
        media2.numberOfSeasons = 1
        media2.watched = .season(11)
        
        let media3 = PlaceholderData.createStaticShow(in: testingUtils.context)
        media3.title = "Media 3"
        media3.numberOfSeasons = 11
        media3.watched = .season(1)
        
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = predicateNotCompletelyWatched
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let results = try testingUtils.context.fetch(fetchRequest)
        
        XCTAssertEqual(results.map(\.title), [media3.title])
    }
    
    func testProblemsPredicate() async throws {
        let context = testingUtils.context
        context.reset()
        
        // MARK: Create sample medias
        let movieTMDBData = try await TMDBAPI.shared.tmdbData(for: 603, type: .movie, context: context)
        let showTMDBData = try await TMDBAPI.shared.tmdbData(for: 46952, type: .show, context: context)
        
        let sampleTags: Set<Tag> = [
            Tag(name: "Tag 1", context: context),
            Tag(name: "Tag 2", context: context),
            Tag(name: "Tag 3", context: context),
        ]
        
        func baseMovie() -> Movie {
            Movie(context: context, tmdbData: movieTMDBData)
        }
        
        func baseShow() -> Show {
            Show(context: context, tmdbData: showTMDBData)
        }
        
        var problemsMedias: [Media] = []
        var noProblemsMedias: [Media] = []
        
        // MARK: No Problems
        
        context.performAndWait {
            noProblemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieComplete1"
                movie.personalRating = .fiveStars
                movie.watched = .watched
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            noProblemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieComplete2"
                movie.personalRating = .halfStar
                movie.watched = .partially
                movie.watchAgain = false
                movie.tags = [sampleTags.first!]
                movie.notes = ""
                return movie
            }())
            
            noProblemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingNote"
                movie.personalRating = .fiveStars
                movie.watched = .watched
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = ""
                return movie
            }())
            
            noProblemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingAllIsNotWatched"
                movie.personalRating = .noRating
                movie.watched = .notWatched
                movie.watchAgain = nil
                movie.tags = []
                movie.notes = ""
                return movie
            }())
            
            noProblemsMedias.append({
                let show = baseShow()
                show.title = "showComplete1"
                show.personalRating = .fiveStars
                show.watched = .season(show.numberOfSeasons!)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            noProblemsMedias.append({
                let show = baseShow()
                show.title = "showComplete2"
                show.personalRating = .fiveStars
                show.watched = .season(show.numberOfSeasons! - 1)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            noProblemsMedias.append({
                let show = baseShow()
                show.title = "showComplete3"
                show.personalRating = .fiveStars
                show.watched = .episode(season: 1, episode: 3)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            noProblemsMedias.append({
                let show = baseShow()
                show.title = "showMissingNote"
                show.personalRating = .fiveStars
                show.watched = .season(show.numberOfSeasons!)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = ""
                return show
            }())
            
            noProblemsMedias.append({
                let show = baseShow()
                show.title = "showMissingAllIsNotWatched"
                show.personalRating = .noRating
                show.watched = .notWatched
                show.watchAgain = nil
                show.tags = []
                show.notes = ""
                return show
            }())
            
            // MARK: Problems
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingWatched"
                movie.personalRating = .fiveStars
                movie.watched = nil
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingRating1"
                movie.personalRating = .noRating
                movie.watched = .watched
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingRating2"
                movie.personalRating = .noRating
                movie.watched = .partially
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingRatingWatched"
                movie.personalRating = .noRating
                movie.watched = nil
                movie.watchAgain = true
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingWatchAgain"
                movie.personalRating = .fiveStars
                movie.watched = .watched
                movie.watchAgain = nil
                movie.tags = sampleTags
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingTags"
                movie.personalRating = .fiveStars
                movie.watched = .watched
                movie.watchAgain = true
                movie.tags = []
                movie.notes = "Note"
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingAll"
                movie.personalRating = .noRating
                movie.watched = nil
                movie.watchAgain = nil
                movie.tags = []
                movie.notes = ""
                return movie
            }())
            
            problemsMedias.append({
                let movie = baseMovie()
                movie.title = "movieMissingAll2"
                return movie
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingAll"
                show.personalRating = .noRating
                show.watched = nil
                show.watchAgain = nil
                show.tags = []
                show.notes = ""
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingRating1"
                show.personalRating = .noRating
                show.watched = .season(show.numberOfSeasons!)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingRating2"
                show.personalRating = .noRating
                show.watched = .episode(season: 1, episode: 3)
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingWatched"
                show.personalRating = .fiveStars
                show.watched = nil
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingWatchedRating"
                show.personalRating = .noRating
                show.watched = nil
                show.watchAgain = true
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingWatchAgain"
                show.personalRating = .fiveStars
                show.watched = .season(show.numberOfSeasons!)
                show.watchAgain = nil
                show.tags = sampleTags
                show.notes = "Note"
                return show
            }())
            
            problemsMedias.append({
                let show = baseShow()
                show.title = "showMissingTags"
                show.personalRating = .fiveStars
                show.watched = .season(show.numberOfSeasons!)
                show.watchAgain = true
                show.tags = []
                show.notes = "Note"
                return show
            }())
        }
        
        context.performAndWait {
            context.processPendingChanges()
        }
        
        // Check if all movies/shows have been properly created
        let allObjects = try context.fetch(Media.fetchRequest())
        XCTAssertEqual(allObjects.count, problemsMedias.count + noProblemsMedias.count, "There are missing/duplicated medias in the context.")
        
        let predicate = PredicateMediaList.problems.predicate
        
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = predicate
        
        let fetchedProblems = try context.fetch(fetchRequest)
        
        // swiftlint:disable:next force_cast
        let problems = NSArray(array: problemsMedias + noProblemsMedias).filtered(using: predicate) as! [Media]
        
        // MARK: Problems
        // All medias that are problematic should be included in the filtered results
        for media in problemsMedias {
            XCTAssert(problems.contains(media), "\(media.title) is not identified as a problem.")
        }
        // Fetched results:
        for media in problemsMedias {
            XCTAssert(fetchedProblems.contains(media), "\(media.title) is not identified as a problem when fetching.")
        }
        
        // MARK: No Problems
        // All medias that are not problematic should not be included
        for media in noProblemsMedias {
            XCTAssert(!problems.contains(media), "\(media.title) is wrongfully identified as a problem.")
        }
        // Fetched results:
        for media in noProblemsMedias {
            XCTAssert(!fetchedProblems.contains(media), "\(media.title) is wrongfully identified as a problem when fetching.")
        }
    }
    
    func testAnyPredicate() throws {
        let show = PlaceholderData.createStaticShow(in: testingUtils.context)
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
