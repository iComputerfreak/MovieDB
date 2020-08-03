//
//  CSVCoderTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 03.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class CSVCoderTests: XCTestCase {
    
    var csvCoder: CSVCoder!
    
    override func setUp() {
        csvCoder = CSVCoder()
    }
    
    override func tearDown() {
        csvCoder = nil
    }
    
    // TODO: Notes field in editing view is too small
    // TODO: Make sure that notes don't contain ; or line breaks (because of csv)
    // TODO: Change CSVCoder to im-/export tags and genres as names only
    
    func testDecode() throws {
        let sample1 = """
        id;tmdb_id;type;title;personal_rating;watch_again;tags;notes;original_title;genres;overview;status;watched;release_date;runtime;budget;revenue;is_adult;last_episode_watched;first_air_date;last_air_date;number_of_seasons;is_in_production;show_type
        113;346808;movie;Momentum;8;true;Female Lead,Gangsters,Kidnapping,Revenge;;Momentum;Action,Thriller;When Alex, an infiltration expert with a secret past, accidentally reveals her identity during what should have been a routine heist, she quickly finds herself mixed up in a government conspiracy and entangled in a deadly game of cat-and-mouse with a master assassin and his team of killers.  Armed with her own set of lethal skills, Alex looks to exact revenge for her murdered friends while uncovering the truth.;Released;true;2015-08-01;96;20000000;133332;false;;;;;;
        157;75219;tv;9-1-1;2;true;Crime;A very great series;9-1-1;Drama,Action & Adventure,Crime;Explore the high-pressure experiences of police officers, paramedics and firefighters who are thrust into the most frightening, shocking and heart-stopping situations. These emergency responders must try to balance saving those who are at their most vulnerable with solving the problems in their own lives.;Returning Series;;;;;;;3;2018-01-03;2020-05-11;3;true;Scripted
        125;79130;tv;Another Life;1;false;Artificial Intelligence,Aliens,Female Lead,Haunted,Future,Horror,Space,Extinction Level Event;;Another Life;Drama,Sci-Fi & Fantasy;After a massive alien artifact lands on Earth, Niko Breckinridge leads an interstellar mission to track down its source and make first contact.;Returning Series;;;;;;;3/5;2019-07-25;2019-07-25;1;true;Scripted
        116;399402;movie;Hunter Killer;0;false;Ships,War,Tom Cruise Style;A note with some special characters.\\/:?!;Hunter Killer;Action,Thriller;Captain Glass of the USS Arkansas discovers that a coup d'état is taking place in Russia, so he and his crew join an elite group working on the ground to prevent a war.;Released;true;2018-10-19;122;0;0;false;;;;;;
        """
        let mediaObjects = try csvCoder.decode(sample1)
        XCTAssertEqual(mediaObjects.count, 4)
        
        // MARK: Momentum
        XCTAssertEqual(mediaObjects[0].type, .movie)
        let momentum = try XCTUnwrap(mediaObjects[0] as? Movie)
        try testDecodeMomentum(momentum)
        
        // MARK: 9-1-1
        XCTAssertEqual(mediaObjects[1].type, .show)
        let nineOneOne = try XCTUnwrap(mediaObjects[1] as? Show)
        try testDecodeNineOneOne(nineOneOne)
        
        // MARK: Another Life
        XCTAssertEqual(mediaObjects[2].type, .show)
        let anotherLife = try XCTUnwrap(mediaObjects[2] as? Show)
        try testDecodeAnotherLife(anotherLife)
        
        // MARK: Hunter Killer
        XCTAssertEqual(mediaObjects[3].type, .movie)
        let hunterKiller = try XCTUnwrap(mediaObjects[3] as? Movie)
        try testDecodeHunterKiller(hunterKiller)
    }
    
    private func testDecodeMomentum(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 346808)
        XCTAssertEqual(media.tmdbData?.title, "Momentum")
        XCTAssertEqual(media.personalRating, .fourStars)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Female Lead", "Gangsters", "Kidnapping", "Revenge"])
        XCTAssertEqual(media.notes, "")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBMovieData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Momentum")
        XCTAssertEqual((momentumTMDBData as? TMDBMovieData)?.isAdult, false)
        
        XCTAssertEqual(media.watched, true)
    }
    
    private func testDecodeNineOneOne(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 75219)
        XCTAssertEqual(media.tmdbData?.title, "9-1-1")
        XCTAssertEqual(media.personalRating, .oneStar)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Crime"])
        XCTAssertEqual(media.notes, "A very great series")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBShowData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "9-1-1")
        XCTAssertEqual((momentumTMDBData as? TMDBShowData)?.type, .scripted)
        
        XCTAssertEqual(media.lastEpisodeWatched, .init(season: 3))
    }
    
    private func testDecodeAnotherLife(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 79130)
        XCTAssertEqual(media.tmdbData?.title, "Another Life")
        XCTAssertEqual(media.personalRating, .halfStar)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Artificial Intelligence", "Aliens", "Female Lead", "Haunted", "Future", "Horror", "Space", "Extinction Level Event"])
        XCTAssertEqual(media.notes, "")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBShowData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Another Life")
        XCTAssertEqual((momentumTMDBData as? TMDBShowData)?.type, .scripted)
        
        XCTAssertEqual(media.lastEpisodeWatched, .init(season: 3, episode: 5))
    }
    
    private func testDecodeHunterKiller(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 399402)
        XCTAssertEqual(media.tmdbData?.title, "Hunter Killer")
        XCTAssertEqual(media.personalRating, .noRating)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Ships", "War", "Tom Cruise Style"])
        XCTAssertEqual(media.notes, "A note with some special characters.\\/:?!")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBMovieData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Hunter Killer")
        XCTAssertEqual((momentumTMDBData as? TMDBMovieData)?.isAdult, false)
        
        XCTAssertEqual(media.watched, true)
    }
    
    func testEncode() {
        // TODO: Use TestingUtils.mediaSamples and check the result CSV for all values!!!
    }

}
