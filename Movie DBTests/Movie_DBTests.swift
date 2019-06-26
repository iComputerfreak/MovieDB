//
//  Movie_DBTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

// TODO: Use rawReleaseDate everywhere!!!
// TODO: Create unit tests for Models Codable implementations

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
        let movie: TMDBMovieData = load("TMDB Movie.json")
        XCTAssertFalse(movie.isAdult)
        XCTAssertEqual(movie.budget, 63000000)
        XCTAssert(movie.genres.contains(where: { $0 == Genre(id: 18, name: "Drama")}))
        XCTAssertEqual(movie.genres.count, 1)
        XCTAssertEqual(movie.homepageURL, "")
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.imdbID, "tt0137523")
        XCTAssertEqual(movie.originalLanguage, "en")
        XCTAssertEqual(movie.originalTitle, "Fight Club")
        XCTAssertEqual(movie.overview, "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        XCTAssertEqual(movie.popularity, 0.5)
        XCTAssertEqual(movie.imagePath, nil)
        for company in companies {
            XCTAssert(movie.productionCompanies.contains(where: { $0 == company }))
        }
        XCTAssertEqual(movie.rawReleaseDate, "1999-10-12")
        XCTAssertNotNil(movie.releaseDate)
        let cal = Calendar.current
        let d = movie.releaseDate
        XCTAssertEqual(cal.component(.year, from: d!), 1999)
        XCTAssertEqual(cal.component(.month, from: d!), 10)
        XCTAssertEqual(cal.component(.day, from: d!), 12)
        XCTAssertEqual(movie.revenue, 100853753)
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.status, "Released")
        XCTAssertEqual(movie.tagline, "How much can you know about yourself if you've never been in a fight?")
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.voteAverage, 7.8)
        XCTAssertEqual(movie.voteCount, 3439)
    }
    
    func testDecodeShow() {
        let show: TMDBShowData = load("TMDB Show.json")
    }
    
    func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        
        guard let file = Bundle(for: Movie_DBTests.self).url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }

}
