//
//  Movie_DBTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class Movie_DBTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    /// Tests the decode and encode functions of TMDBMovieData
    func testDecodeMovie() {
        let companies = [
            ProductionCompany(id: 508, name: "Regency Enterprises", logoPath: "/7PzJdsLGlR7oW4J0J5Xcd0pHGRg.png", originCountry: "US"),
            ProductionCompany(id: 711, name: "Fox 2000 Pictures", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 20555, name: "Taurus Film", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 54050, name: "Linson Films", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 54051, name: "Atman Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 54052, name: "Knickerbocker Films", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 25, name: "20th Century Fox", logoPath: "/qZCc1lty5FzX30aOCVRBLzaVmcp.png", originCountry: "US")
        ]
        
        // Test, if the Decoding works
        let movie: TMDBMovieData = TestingUtils.load("TMDB Movie.json")
        XCTAssertFalse(movie.isAdult)
        XCTAssertEqual(movie.budget, 63000000)
        XCTAssertEqual(movie.genres, [Genre(id: 18, name: "Drama")])
        XCTAssertEqual(movie.genres.count, 1)
        XCTAssertEqual(movie.homepageURL, "")
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.imdbID, "tt0137523")
        XCTAssertEqual(movie.originalLanguage, "en")
        XCTAssertEqual(movie.originalTitle, "Fight Club")
        XCTAssertEqual(movie.overview, "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        XCTAssertEqual(movie.popularity, 0.5)
        XCTAssertEqual(movie.imagePath, nil)
        XCTAssertEqual(movie.productionCompanies, companies)
        XCTAssertEqual(movie.rawReleaseDate, "1999-10-12")
        XCTAssertNotNil(movie.releaseDate)
        testEqualDateParts(movie.releaseDate!, 1999, 10, 12)
        XCTAssertEqual(movie.revenue, 100853753)
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.status, .released)
        XCTAssertEqual(movie.tagline, "How much can you know about yourself if you've never been in a fight?")
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.voteAverage, 7.8)
        XCTAssertEqual(movie.voteCount, 3439)
    }
    
    func testDecodeShow() {
        let companies = [
            ProductionCompany(id: 76043, name: "Revolution Sun Studios", logoPath: "/9RO2vbQ67otPrBLXCaC8UMp3Qat.png", originCountry: "US"),
            ProductionCompany(id: 3268, name: "HBO", logoPath: "/tuomPhY2UtuPTqqFnKMVHvSb724.png", originCountry: "US"),
            ProductionCompany(id: 12525, name: "Television 360", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 5820, name: "Generator Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 12526, name: "Bighead Littlehead", logoPath: nil, originCountry: "")
        ]
        let genres = [
            Genre(id: 10765, name: "Sci-Fi & Fantasy"),
            Genre(id: 18, name: "Drama"),
            Genre(id: 10759, name: "Action & Adventure")
        ]
        let seasons: [Season] = [
            /*Season(id: 3627, seasonNumber: 0, episodeCount: 14, name: "Specials", overview: "", imagePath: "/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg", rawAirDate: "2010-12-05"),
            Season(id: 3624, seasonNumber: 1, episodeCount: 10, name: "Season 1", overview: "Trouble is brewing in the Seven Kingdoms of Westeros. For the driven inhabitants of this visionary world, control of Westeros' Iron Throne holds the lure of great power. But in a land where the seasons can last a lifetime, winter is coming...and beyond the Great Wall that protects them, an ancient evil has returned. In Season One, the story centers on three primary areas: the Stark and the Lannister families, whose designs on controlling the throne threaten a tenuous peace; the dragon princess Daenerys, heir to the former dynasty, who waits just over the Narrow Sea with her malevolent brother Viserys; and the Great Wall--a massive barrier of ice where a forgotten danger is stirring.", imagePath: "/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg", rawAirDate: "2011-04-17"),
            // ...
            Season(id: 81266, seasonNumber: 7, episodeCount: 7, name: "Season 7", overview: "The long winter is here. And with it comes a convergence of armies and attitudes that have been brewing for years.", imagePath: "/3dqzU3F3dZpAripEx9kRnijXbOj.jpg", rawAirDate: "2017-07-16")
            */
        ]
        let networks = [
            ProductionCompany(id: 49, name: "HBO", logoPath: "/tuomPhY2UtuPTqqFnKMVHvSb724.png", originCountry: "US")
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let show: TMDBShowData = TestingUtils.load("TMDB Show.json")
        XCTAssertEqual(show.episodeRuntime, [60])
        XCTAssertEqual(show.rawFirstAirDate, "2011-04-17")
        XCTAssertNotNil(show.firstAirDate)
        testEqualDateParts(show.firstAirDate!, 2011, 04, 17)
        XCTAssertEqual(show.genres, genres)
        XCTAssertEqual(show.homepageURL, "http://www.hbo.com/game-of-thrones")
        XCTAssertEqual(show.id, 1399)
        XCTAssertTrue(show.isInProduction)
        XCTAssertEqual(show.rawLastAirDate, "2017-08-27")
        XCTAssertNotNil(show.lastAirDate)
        testEqualDateParts(show.lastAirDate!, 2017, 08, 27)
        XCTAssertEqual(show.title, "Game of Thrones")
        XCTAssertEqual(show.networks, networks)
        XCTAssertEqual(show.numberOfEpisodes, 67)
        XCTAssertEqual(show.numberOfSeasons, 7)
        XCTAssertEqual(show.originalLanguage, "en")
        XCTAssertEqual(show.originalTitle, "Game of Thrones")
        XCTAssertEqual(show.overview, "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest north. Amidst the war, a neglected military order of misfits, the Night's Watch, is all that stands between the realms of men and icy horrors beyond.")
        XCTAssertEqual(show.popularity, 53.516)
        XCTAssertEqual(show.imagePath, "/gwPSoYUHAKmdyVywgLpKKA4BjRr.jpg")
        XCTAssertEqual(show.productionCompanies, companies)
        // seasons does not contain all seasons. Only some examples
        for season in seasons {
            XCTAssert(show.seasons.contains(season))
        }
        XCTAssertEqual(show.status, .returning)
        XCTAssertEqual(show.type, .scripted)
        XCTAssertEqual(show.voteAverage, 8.2)
        XCTAssertEqual(show.voteCount, 4682)
    }
    
    func testEncode() {
        
        // Decoding is already fully tested. We assume it works correctly
        let movie: TMDBMovieData = TestingUtils.load("TMDB Movie.json")
        let movieData = try? JSONEncoder().encode(movie)
        XCTAssertNotNil(movieData)
        let movie2 = try? JSONDecoder().decode(TMDBMovieData.self, from: movieData!)
        XCTAssertEqual(movie, movie2)
        
        let show: TMDBShowData = TestingUtils.load("TMDB Show.json")
        let showData = try? JSONEncoder().encode(show)
        XCTAssertNotNil(showData)
        let show2 = try? JSONDecoder().decode(TMDBShowData.self, from: showData!)
        XCTAssertEqual(show, show2)
    }
    
    func testEqualDateParts(_ date: Date, _ year: Int, _ month: Int, _ day: Int) {
        let cal = Calendar.current
        XCTAssertEqual(cal.component(.year, from: date), year)
        XCTAssertEqual(cal.component(.month, from: date), month)
        XCTAssertEqual(cal.component(.day, from: date), day)
    }
    
    let api = TMDBAPI.shared
    

}
