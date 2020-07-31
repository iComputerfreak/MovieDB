//
//  CodableTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class CodableTests: XCTestCase {
    
    let api = TMDBAPI.shared
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    /// Tests the decode and encode functions of TMDBMovieData
    func testDecodeMovieMatrix() {
        let companies = [
            ProductionCompany(id: 79, name: "Village Roadshow Pictures", logoPath: "/tpFpsqbleCzEE2p5EgvUq6ozfCA.png", originCountry: "US"),
            ProductionCompany(id: 372, name: "Groucho II Film Partnership", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 1885, name: "Silver Pictures", logoPath: "/xlvoOZr4s1PygosrwZyolIFe5xs.png", originCountry: "US"),
            ProductionCompany(id: 174, name: "Warner Bros. Pictures", logoPath: "/IuAlhI9eVC9Z8UQWOIDdWRKSEJ.png", originCountry: "US")
        ]
        
        // Test, if the Decoding works
        let movie: TMDBMovieData = TestingUtils.load("Matrix.json")
        XCTAssertEqual(movie.id, 603)
        XCTAssertEqual(movie.title, "The Matrix")
        XCTAssertEqual(movie.originalTitle, "The Matrix")
        XCTAssertEqual(movie.imagePath, "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg")
        assertEqual(movie.genres, [Genre(id: 28, name: "Action"), Genre(id: 878, name: "Science Fiction")])
        XCTAssertEqual(movie.overview, "Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.")
        XCTAssertEqual(movie.status, .released)
        XCTAssertEqual(movie.originalLanguage, "en")
        
        XCTAssertEqual(movie.imdbID, "tt0133093")
        assertEqual(movie.productionCompanies, companies)
        XCTAssertEqual(movie.homepageURL, "http://www.warnerbros.com/matrix")
        
        XCTAssertEqual(movie.popularity, 46.593)
        XCTAssertEqual(movie.voteAverage, 8.1)
        XCTAssertEqual(movie.voteCount, 17486)
        
        // Movie exclusive data
        assertEqual(movie.releaseDate, 1999, 03, 30)
        XCTAssertEqual(movie.runtime, 136)
        XCTAssertEqual(movie.budget, 63000000)
        XCTAssertEqual(movie.revenue, 463517383)
        XCTAssertEqual(movie.tagline, "Welcome to the Real World.")
        XCTAssertEqual(movie.isAdult, false)
        
        // Translations, Keywords, Videos and Cast
        // TODO: Add tests for these, after moving them from Media to TMDBData
    }
    
    func testDecodeMovieFightClub() {
        let companies = [
            ProductionCompany(id: 508, name: "Regency Enterprises", logoPath: "/7PzJdsLGlR7oW4J0J5Xcd0pHGRg.png", originCountry: "US"),
            ProductionCompany(id: 711, name: "Fox 2000 Pictures", logoPath: "/tEiIH5QesdheJmDAqQwvtN60727.png", originCountry: "US"),
            ProductionCompany(id: 20555, name: "Taurus Film", logoPath: "/hD8yEGUBlHOcfHYbujp71vD8gZp.png", originCountry: "DE"),
            ProductionCompany(id: 54051, name: "Atman Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 54052, name: "Knickerbocker Films", logoPath: nil, originCountry: "US"),
            ProductionCompany(id: 25, name: "20th Century Fox", logoPath: "/qZCc1lty5FzX30aOCVRBLzaVmcp.png", originCountry: "US"),
            ProductionCompany(id: 4700, name: "The Linson Company", logoPath: "/A32wmjrs9Psf4zw0uaixF0GXfxq.png", originCountry: "")
        ]
        
        // Test, if the Decoding works
        let movie: TMDBMovieData = TestingUtils.load("FightClub.json")
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.originalTitle, "Fight Club")
        XCTAssertEqual(movie.imagePath, "/wR5HZWdVpcXx9sevV1bQi7rP4op.jpg")
        assertEqual(movie.genres, [Genre(id: 18, name: "Drama")])
        XCTAssertEqual(movie.overview, "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        XCTAssertEqual(movie.status, .released)
        XCTAssertEqual(movie.originalLanguage, "en")
        
        XCTAssertEqual(movie.imdbID, "tt0137523")
        assertEqual(movie.productionCompanies, companies)
        XCTAssertEqual(movie.homepageURL, "http://www.foxmovies.com/movies/fight-club")
        
        XCTAssertEqual(movie.popularity, 47.709)
        XCTAssertEqual(movie.voteAverage, 8.4)
        XCTAssertEqual(movie.voteCount, 19730)
        
        // Movie exclusive data
        assertEqual(movie.releaseDate, 1999, 10, 15)
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.budget, 63000000)
        XCTAssertEqual(movie.revenue, 100853753)
        XCTAssertEqual(movie.tagline, "Mischief. Mayhem. Soap.")
        XCTAssertEqual(movie.isAdult, false)
        
        // Translations, Keywords, Videos and Cast
        // TODO: Add tests for these, after moving them from Media to TMDBData
    }
    
    func testDecodeShowBlacklist() {
        let companies = [
            ProductionCompany(id: 11073, name: "Sony Pictures Television", logoPath: "/wHs44fktdoj6c378ZbSWfzKsM2Z.png", originCountry: "US")
        ]
        let networks = [
            ProductionCompany(id: 6, name: "NBC", logoPath: "/o3OedEP0f9mfZr33jz2BfXOUK5.png", originCountry: "US")
        ]
        let seasons = [
            Season(id: 55083, seasonNumber: 0, episodeCount: 7, name: "Specials",
                   overview: "",
                   imagePath: "/jPT3J4xlQ3yF5fczAopLofHBGq3.jpg", rawAirDate: "2013-09-10"),
            Season(id: 55082, seasonNumber: 1, episodeCount: 22, name: "Season 1",
                   overview: "",
                   imagePath: "/ccrCgW1ukxgwBue9ptkpCEjXE6q.jpg", rawAirDate: "2013-09-23"),
            Season(id: 61357, seasonNumber: 2, episodeCount: 22, name: "Season 2",
                   overview: "",
                   imagePath: "/b7o8AOpZPWJO8nP4SK8RRZ2d0B0.jpg", rawAirDate: "2014-09-22"),
            Season(id: 70935, seasonNumber: 3, episodeCount: 23, name: "Season 3",
                   overview: "Now a fugitive on the run, Liz must figure out how to protect herself from the fallout of her actions in the explosive season two finale.",
                   imagePath: "/hWN5imHrpg8wjEBsa7v80sGsS8r.jpg", rawAirDate: "2015-10-01"),
            Season(id: 80082, seasonNumber: 4, episodeCount: 22, name: "Season 4",
                   overview: "A mysterious man claiming to be Liz’s real father targets her, but first she must resolve the mystery of her lost childhood and reconcile her true identity with the elusive memories corrupted by Reddington. Without the truth, every day holds more danger for herself, her baby and her husband Tom. Meanwhile, the Task Force reels from Liz’s resurrection and friendships are fractured. Betrayed by those closest to him, Reddington’s specific moral code demands justice, all the while battling an army of new and unexpected blacklisters.",
                   imagePath: "/d5AJOxPzGkAHiaCHcESVCim1vHu.jpg", rawAirDate: "2016-09-22"),
            Season(id: 91328, seasonNumber: 5, episodeCount: 22, name: "Season 5",
                   overview: "Feeling surprisingly unencumbered, Raymond Reddington is back, and in the process of rebuilding his criminal empire. His lust for life is ever-present as he lays the foundation for this new enterprise - one that he'll design with Elizabeth Keen by his side. Living with the reality that Red is her father, Liz finds herself torn between her role as an FBI agent and the temptation to act on her more criminal instincts. In a world where the search for Blacklisters has become a family trade, Red will undoubtedly reclaim his moniker as the “Concierge of Crime.”",
                   imagePath: "/6MupSEjQbWd5t37iHoYNGV1Rp2Y.jpg", rawAirDate: "2017-09-27"),
            Season(id: 112279, seasonNumber: 6, episodeCount: 22, name: "Season 6",
                   overview: "Following the startling revelation that Raymond \"Red\" Reddington isn't who he says he is, Elizabeth Keen is torn between the relationship she's developed with the man assumed to be her father and her desire to get to the bottom of years of secrets and lies. Meanwhile, Red leads Liz and the FBI to some of the most strange and dangerous criminals yet, growing his empire and eliminating rivals in the process. All throughout, Liz and Red engage in an uneasy cat-and-mouse game in which lines will be crossed and the truth will be revealed.",
                   imagePath: "/cJZbQFPm2GuD2K4FvksOncRGNzm.jpg", rawAirDate: "2019-01-03"),
            Season(id: 132066, seasonNumber: 7, episodeCount: 19, name: "Season 7",
                   overview: "",
                   imagePath: "/zBnDzqCYOcvl8OmC53Hzd7W5hiZ.jpg", rawAirDate: "2019-10-04")
        ]
        
        // Test, if the Decoding works
        let show: TMDBShowData = TestingUtils.load("Blacklist.json")
        XCTAssertEqual(show.id, 46952)
        XCTAssertEqual(show.title, "The Blacklist")
        XCTAssertEqual(show.originalTitle, "The Blacklist")
        XCTAssertEqual(show.imagePath, "/bgbQCW4fE9b6wSOSC6Fb4FfVzsW.jpg")
        assertEqual(show.genres, [Genre(id: 18, name: "Drama"), Genre(id: 80, name: "Crime"), Genre(id: 9648, name: "Mystery")])
        XCTAssertEqual(show.overview, "Raymond \"Red\" Reddington, one of the FBI's most wanted fugitives, surrenders in person at FBI Headquarters in Washington, D.C. He claims that he and the FBI have the same interests: bringing down dangerous criminals and terrorists. In the last two decades, he's made a list of criminals and terrorists that matter the most but the FBI cannot find because it does not know they exist. Reddington calls this \"The Blacklist\". Reddington will co-operate, but insists that he will speak only to Elizabeth Keen, a rookie FBI profiler.")
        XCTAssertEqual(show.status, .returning)
        XCTAssertEqual(show.originalLanguage, "en")
        
        assertEqual(show.productionCompanies, companies)
        XCTAssertEqual(show.homepageURL, "http://www.nbc.com/the-blacklist")
        
        XCTAssertEqual(show.popularity, 121.501)
        XCTAssertEqual(show.voteAverage, 7.2)
        XCTAssertEqual(show.voteCount, 1539)
        
        // Show exclusive data
        assertEqual(show.firstAirDate, 2013, 09, 23)
        assertEqual(show.lastAirDate, 2020, 05, 15)
        XCTAssertEqual(show.numberOfSeasons, 7)
        XCTAssertEqual(show.numberOfEpisodes, 152)
        XCTAssertEqual(show.episodeRuntime, [43])
        XCTAssertEqual(show.isInProduction, true)
        assertEqual(show.seasons, seasons)
        XCTAssertEqual(show.type, .scripted)
        assertEqual(show.networks, networks)
        
        // Translations, Keywords, Videos and Cast
        // TODO: Add tests for these, after moving them from Media to TMDBData
    }
    
    func testDecodeShowGameOfThrones() {
        let companies = [
            ProductionCompany(id: 76043, name: "Revolution Sun Studios", logoPath: "/9RO2vbQ67otPrBLXCaC8UMp3Qat.png", originCountry: "US"),
            ProductionCompany(id: 12525, name: "Television 360", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 5820, name: "Generator Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany(id: 12526, name: "Bighead Littlehead", logoPath: nil, originCountry: "")
        ]
        let networks = [
            ProductionCompany(id: 49, name: "HBO", logoPath: "/tuomPhY2UtuPTqqFnKMVHvSb724.png", originCountry: "US")
        ]
        let seasons = [
            Season(id: 3627, seasonNumber: 0, episodeCount: 53, name: "Specials",
                   overview: "",
                   imagePath: "/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg", rawAirDate: "2010-12-05"),
            Season(id: 3624, seasonNumber: 1, episodeCount: 10, name: "Season 1",
                   overview: "Trouble is brewing in the Seven Kingdoms of Westeros. For the driven inhabitants of this visionary world, control of Westeros' Iron Throne holds the lure of great power. But in a land where the seasons can last a lifetime, winter is coming...and beyond the Great Wall that protects them, an ancient evil has returned. In Season One, the story centers on three primary areas: the Stark and the Lannister families, whose designs on controlling the throne threaten a tenuous peace; the dragon princess Daenerys, heir to the former dynasty, who waits just over the Narrow Sea with her malevolent brother Viserys; and the Great Wall--a massive barrier of ice where a forgotten danger is stirring.",
                   imagePath: "/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg", rawAirDate: "2011-04-17"),
            Season(id: 3625, seasonNumber: 2, episodeCount: 10, name: "Season 2",
                   overview: "The cold winds of winter are rising in Westeros...war is coming...and five kings continue their savage quest for control of the all-powerful Iron Throne. With winter fast approaching, the coveted Iron Throne is occupied by the cruel Joffrey, counseled by his conniving mother Cersei and uncle Tyrion. But the Lannister hold on the Throne is under assault on many fronts. Meanwhile, a new leader is rising among the wildings outside the Great Wall, adding new perils for Jon Snow and the order of the Night's Watch.",
                   imagePath: "/5tuhCkqPOT20XPwwi9NhFnC1g9R.jpg", rawAirDate: "2012-04-01"),
            Season(id: 3626, seasonNumber: 3, episodeCount: 10, name: "Season 3",
                   overview: "Duplicity and treachery...nobility and honor...conquest and triumph...and, of course, dragons. In Season 3, family and loyalty are the overarching themes as many critical storylines from the first two seasons come to a brutal head. Meanwhile, the Lannisters maintain their hold on King's Landing, though stirrings in the North threaten to alter the balance of power; Robb Stark, King of the North, faces a major calamity as he tries to build on his victories; a massive army of wildlings led by Mance Rayder march for the Wall; and Daenerys Targaryen--reunited with her dragons--attempts to raise an army in her quest for the Iron Throne.",
                   imagePath: "/7d3vRgbmnrRQ39Qmzd66bQyY7Is.jpg", rawAirDate: "2013-03-31"),
            Season(id: 3628, seasonNumber: 4, episodeCount: 10, name: "Season 4",
                   overview: "The War of the Five Kings is drawing to a close, but new intrigues and plots are in motion, and the surviving factions must contend with enemies not only outside their ranks, but within.",
                   imagePath: "/dniQ7zw3mbLJkd1U0gdFEh4b24O.jpg", rawAirDate: "2014-04-06"),
            Season(id: 62090, seasonNumber: 5, episodeCount: 10, name: "Season 5",
                   overview: "The War of the Five Kings, once thought to be drawing to a close, is instead entering a new and more chaotic phase. Westeros is on the brink of collapse, and many are seizing what they can while the realm implodes, like a corpse making a feast for crows.",
                   imagePath: "/527sR9hNDcgVDKNUE3QYra95vP5.jpg", rawAirDate: "2015-04-12"),
            Season(id: 71881, seasonNumber: 6, episodeCount: 10, name: "Season 6",
                   overview: "Following the shocking developments at the conclusion of season five, survivors from all parts of Westeros and Essos regroup to press forward, inexorably, towards their uncertain individual fates. Familiar faces will forge new alliances to bolster their strategic chances at survival, while new characters will emerge to challenge the balance of power in the east, west, north and south.",
                   imagePath: "/zvYrzLMfPIenxoq2jFY4eExbRv8.jpg", rawAirDate: "2016-04-24"),
            Season(id: 81266, seasonNumber: 7, episodeCount: 7, name: "Season 7",
                   overview: "The long winter is here. And with it comes a convergence of armies and attitudes that have been brewing for years.",
                   imagePath: "/3dqzU3F3dZpAripEx9kRnijXbOj.jpg", rawAirDate: "2017-07-16"),
            Season(id: 107971, seasonNumber: 8, episodeCount: 6, name: "Season 8",
                   overview: "The Great War has come, the Wall has fallen and the Night King's army of the dead marches towards Westeros. The end is here, but who will take the Iron Throne?",
                   imagePath: "/39FHkTLnNMjMVXdIDwZN8SxYqD6.jpg", rawAirDate: "2019-04-14")
        ]
        
        // Test, if the Decoding works
        let show: TMDBShowData = TestingUtils.load("GameOfThrones.json")
        XCTAssertEqual(show.id, 1399)
        XCTAssertEqual(show.title, "Game of Thrones")
        XCTAssertEqual(show.originalTitle, "Game of Thrones")
        XCTAssertEqual(show.imagePath, "/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg")
        assertEqual(show.genres, [Genre(id: 10765, name: "Sci-Fi & Fantasy"), Genre(id: 18, name: "Drama")])
        XCTAssertEqual(show.overview, "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest north. Amidst the war, a neglected military order of misfits, the Night's Watch, is all that stands between the realms of men and icy horrors beyond.")
        XCTAssertEqual(show.status, .ended)
        XCTAssertEqual(show.originalLanguage, "en")
        
        assertEqual(show.productionCompanies, companies)
        XCTAssertEqual(show.homepageURL, "http://www.hbo.com/game-of-thrones")
        
        XCTAssertEqual(show.popularity, 141.052)
        XCTAssertEqual(show.voteAverage, 8.3)
        XCTAssertEqual(show.voteCount, 9413)
        
        // Show exclusive data
        assertEqual(show.firstAirDate, 2011, 04, 17)
        assertEqual(show.lastAirDate, 2019, 05, 19)
        XCTAssertEqual(show.numberOfSeasons, 8)
        XCTAssertEqual(show.numberOfEpisodes, 73)
        XCTAssertEqual(show.episodeRuntime, [60])
        XCTAssertEqual(show.isInProduction, false)
        assertEqual(show.seasons, seasons)
        XCTAssertEqual(show.type, .scripted)
        assertEqual(show.networks, networks)
        
        // Translations, Keywords, Videos and Cast
        // TODO: Add tests for these, after moving them from Media to TMDBData
    }
    
    /// De- and then encodes all four examples to check, if any errors occur while encoding
    func testEncode() throws {
        // Load the media objects from JSON
        let matrix: TMDBMovieData = TestingUtils.load("Matrix.json")
        XCTAssertNotNil(matrix)
        let fightClub: TMDBMovieData = TestingUtils.load("FightClub.json")
        XCTAssertNotNil(fightClub)
        let blacklist: TMDBShowData = TestingUtils.load("Blacklist.json")
        XCTAssertNotNil(blacklist)
        let gameOfThrones: TMDBShowData = TestingUtils.load("GameOfThrones.json")
        XCTAssertNotNil(gameOfThrones)
        
        // Encode them back into JSON
        let encoder = JSONEncoder()
        let matrixData = try encoder.encode(matrix)
        let fightClubData = try encoder.encode(fightClub)
        let blacklistData = try encoder.encode(blacklist)
        let gameOfThronesData = try encoder.encode(gameOfThrones)
        
        // Now load them again and compare them to the original values
        let decoder = JSONDecoder()
        let matrixLoaded = try decoder.decode(TMDBMovieData.self, from: matrixData)
        XCTAssertEqual(matrix, matrixLoaded)
        let fightClubLoaded = try decoder.decode(TMDBMovieData.self, from: fightClubData)
        XCTAssertEqual(fightClub, fightClubLoaded)
        let blacklistLoaded = try decoder.decode(TMDBShowData.self, from: blacklistData)
        XCTAssertEqual(blacklist, blacklistLoaded)
        let gameOfThronesLoaded = try decoder.decode(TMDBShowData.self, from: gameOfThronesData)
        XCTAssertEqual(gameOfThrones, gameOfThronesLoaded)
    }
    
}
