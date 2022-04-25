//
//  CodableTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB
import CoreData

// swiftlint:disable line_length
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
class CodableTests: XCTestCase {
    let api = TMDBAPI.shared
    // swiftlint:disable:next implicitly_unwrapped_optional
    var testingUtils: TestingUtils!
    
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
    }
    
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
    }
        
    /// Tests the decode and encode functions of TMDBMovieData
    func testDecodeMovieMatrix() throws {
        let companies = [
            ProductionCompany.create(context: testContext, id: 79, name: "Village Roadshow Pictures", logoPath: "/tpFpsqbleCzEE2p5EgvUq6ozfCA.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 372, name: "Groucho II Film Partnership", logoPath: nil, originCountry: ""),
            ProductionCompany.create(context: testContext, id: 1885, name: "Silver Pictures", logoPath: "/xlvoOZr4s1PygosrwZyolIFe5xs.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 174, name: "Warner Bros. Pictures", logoPath: "/IuAlhI9eVC9Z8UQWOIDdWRKSEJ.png", originCountry: "US")
        ]
        
        // Test, if the Decoding works
        let movie: TMDBData = TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
        XCTAssertEqual(movie.id, 603)
        XCTAssertEqual(movie.title, "The Matrix")
        XCTAssertEqual(movie.originalTitle, "The Matrix")
        XCTAssertEqual(movie.imagePath, "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg")
        assertEqual(movie.genres, [Genre.create(context: testContext, id: 28, name: "Action"), Genre.create(context: testContext, id: 878, name: "Science Fiction")])
        XCTAssertEqual(movie.overview, "Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.")
        XCTAssertEqual(movie.status, .released)
        XCTAssertEqual(movie.originalLanguage, "en")
        
        assertEqual(movie.productionCompanies, companies)
        XCTAssertEqual(movie.homepageURL, "http://www.warnerbros.com/matrix")
        
        XCTAssertEqual(movie.popularity, 92.66)
        XCTAssertEqual(movie.voteAverage, 8.2)
        XCTAssertEqual(movie.voteCount, 21445)
        
        // Movie exclusive data
        let movieData = try XCTUnwrap(movie.movieData)
        
        XCTAssertEqual(movieData.imdbID, "tt0133093")
        assertEqual(movieData.releaseDate, 1999, 03, 30)
        XCTAssertEqual(movieData.runtime, 136)
        XCTAssertEqual(movieData.budget, 63000000)
        XCTAssertEqual(movieData.revenue, 463517383)
        XCTAssertEqual(movieData.tagline, "Welcome to the Real World.")
        XCTAssertEqual(movieData.isAdult, false)
        
        // Translations, Keywords, Videos and Cast
        let keywords = ["saving the world", "artificial intelligence", "man vs machine", "philosophy", "prophecy", "martial arts", "self sacrifice", "dream", "fight", "hacker", "insurgence", "simulated reality ", "virtual reality", "dystopia", "truth", "cyberpunk", "dream world", "woman director", "messiah", "action hero", "gnosticism"]
        let translations = ["Arabic", "Bulgarian", "Bosnian", "Catalan", "Czech", "Danish", "German", "Greek", "English", "Spanish", "Spanish", "Persian", "Finnish", "French", "French", "Galician", "Hebrew", "Croatian", "Hungarian", "Indonesian", "Italian", "Japanese", "Georgian", "Korean", "Lithuanian", "Latvian", "Macedonian", "Dutch", "Norwegian", "Polish", "Portuguese", "Portuguese", "Romanian", "Russian", "Slovak", "Slovenian", "Serbian", "Swedish", "Thai", "Turkish", "Ukrainian", "Uzbek", "Vietnamese", "Mandarin", "Mandarin", "Mandarin"]
        let videos = [
            Video.create(context: testContext, key: "nUEQNVV3Gfs", name: "Official 4K Trailer", site: "YouTube", type: "Trailer", resolution: 2160, language: "en", region: "US"),
            Video.create(context: testContext, key: "RZ-MXBjvA38", name: "Full Movie Preview", site: "YouTube", type: "Clip", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "L0fw0WzFaBM", name: "20th Anniversary UK Trailer", site: "YouTube", type: "Trailer", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "m8e-FF8MsqU", name: "Classic Trailer", site: "YouTube", type: "Trailer", resolution: 720, language: "en", region: "US")
        ]
        // Just a few. Too many to write all down
        let cast = [
            CastMember.create(context: testContext, id: 6384, name: "Keanu Reeves", roleName: "Thomas A. Anderson / Neo", imagePath: "/rRdru6REr9i3WIHv2mntpcgxnoY.jpg"),
            CastMember.create(context: testContext, id: 9376, name: "Belinda McClory", roleName: "Switch", imagePath: "/wfTCwkIDJjH5k5DtuvcjP52PrLc.jpg"),
            CastMember.create(context: testContext, id: 1209249, name: "David O'Connor", roleName: "FedEx Man", imagePath: nil),
            CastMember.create(context: testContext, id: 1209257, name: "Rana Morrison", roleName: "Shaylea", imagePath: nil)
        ]
        
        assertEqual(movie.keywords, keywords)
        assertEqual(movie.translations, translations)
        assertEqual(movie.videos, videos)
        assertContains(cast, in: movie.cast)
    }
    
    func testDecodeMovieFightClub() throws {
        let companies = [
            ProductionCompany.create(context: testContext, id: 508, name: "Regency Enterprises", logoPath: "/7PzJdsLGlR7oW4J0J5Xcd0pHGRg.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 711, name: "Fox 2000 Pictures", logoPath: "/tEiIH5QesdheJmDAqQwvtN60727.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 20555, name: "Taurus Film", logoPath: "/hD8yEGUBlHOcfHYbujp71vD8gZp.png", originCountry: "DE"),
            ProductionCompany.create(context: testContext, id: 54051, name: "Atman Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany.create(context: testContext, id: 54052, name: "Knickerbocker Films", logoPath: nil, originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 4700, name: "The Linson Company", logoPath: "/A32wmjrs9Psf4zw0uaixF0GXfxq.png", originCountry: "US")
        ]
        
        // Test, if the Decoding works
        let movie: TMDBData = TestingUtils.load("FightClub.json", mediaType: .movie, into: testContext)
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.originalTitle, "Fight Club")
        XCTAssertEqual(movie.imagePath, "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
        assertEqual(movie.genres, [Genre.create(context: testContext, id: 18, name: "Drama")])
        XCTAssertEqual(movie.overview, "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        XCTAssertEqual(movie.status, .released)
        XCTAssertEqual(movie.originalLanguage, "en")
        
        assertEqual(movie.productionCompanies, companies)
        XCTAssertEqual(movie.homepageURL, "http://www.foxmovies.com/movies/fight-club")
        
        XCTAssertEqual(movie.popularity, 76.058)
        XCTAssertEqual(movie.voteAverage, 8.4)
        XCTAssertEqual(movie.voteCount, 23943)
        
        // Movie exclusive data
        let movieData = try XCTUnwrap(movie.movieData)
        
        XCTAssertEqual(movieData.imdbID, "tt0137523")
        assertEqual(movieData.releaseDate, 1999, 10, 15)
        XCTAssertEqual(movieData.runtime, 139)
        XCTAssertEqual(movieData.budget, 63000000)
        XCTAssertEqual(movieData.revenue, 100853753)
        XCTAssertEqual(movieData.tagline, "Mischief. Mayhem. Soap.")
        XCTAssertEqual(movieData.isAdult, false)
        
        // Translations, Keywords, Videos and Cast
        let keywords = ["based on novel or book", "support group", "dual identity", "nihilism", "fight", "rage and hate", "insomnia", "dystopia", "alter ego", "cult film", "split personality", "quitting a job", "dissociative identity disorder", "self destructiveness"]
        let translations = ["Arabic", "Azerbaijani", "Bulgarian", "Czech", "Danish", "German", "Greek", "English", "Spanish", "Spanish", "Estonian", "Persian", "Finnish", "French", "French", "Hebrew", "Croatian", "Hungarian", "Italian", "Japanese", "Georgian", "Korean", "Lithuanian", "Latvian", "Macedonian", "Malayalam", "Dutch", "Norwegian", "Polish", "Portuguese", "Portuguese", "Romanian", "Russian", "Slovak", "Slovenian", "Serbian", "Swedish", "Thai", "Turkish", "Twi", "Ukrainian", "Uzbek", "Vietnamese", "Mandarin", "Mandarin", "Mandarin"]
        let videos = [
            Video.create(context: testContext, key: "BdJKm16Co6M", name: "#TBT Trailer", site: "YouTube", type: "Trailer", resolution: 1080, language: "en", region: "US")
        ]
        // Just a few. Too many to write all down
        let cast = [
            CastMember.create(context: testContext, id: 819, name: "Edward Norton", roleName: "The Narrator", imagePath: "/5XBzD5WuTyVQZeS4VI25z2moMeY.jpg"),
            CastMember.create(context: testContext, id: 7498, name: "Eion Bailey", roleName: "Ricky", imagePath: "/hKqfGq1sPhZdQOlto0bS3igFZdP.jpg"),
            CastMember.create(context: testContext, id: 1657018, name: "Summer Moore", roleName: "Marla's Neighbor (uncredited)", imagePath: "/9stkBho2p586irYICd6apsb1xr9.jpg")
        ]
        
        assertEqual(movie.keywords, keywords)
        assertEqual(movie.translations, translations)
        assertEqual(movie.videos, videos)
        assertContains(cast, in: movie.cast)
    }
    
    // swiftlint:disable:next inclusive_language
    func testDecodeShowBlacklist() throws {
        let companies = [
            ProductionCompany.create(context: testContext, id: 11073, name: "Sony Pictures Television Studios", logoPath: "/wHs44fktdoj6c378ZbSWfzKsM2Z.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 1302, name: "Davis Entertainment", logoPath: "/kQZtJdyphCmq292iGDqlUx0yk2D.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 26727, name: "Universal Television", logoPath: "/jeTxdjXhzgKZyLr3l9MllkTn3fy.png", originCountry: "US")
        ]
        let networks = [
            ProductionCompany.create(context: testContext, id: 6, name: "NBC", logoPath: "/nGRVQlfmPBmfkNgCFpx5m7luTxG.png", originCountry: "US")
        ]
        // swiftlint:disable vertical_parameter_alignment_on_call
        // swiftlint:disable multiline_arguments
        // swiftlint:disable multiline_arguments_brackets
        let seasons = [
            Season.create(context: testContext, id: 55083, seasonNumber: 0, episodeCount: 11, name: "Specials",
                   overview: "",
                   imagePath: "/jPT3J4xlQ3yF5fczAopLofHBGq3.jpg", rawAirDate: "2013-09-10"),
            Season.create(context: testContext, id: 55082, seasonNumber: 1, episodeCount: 22, name: "Season 1",
                   overview: "For decades, ex-government agent Raymond \"Red\" Reddington has been one of the FBI’s Most Wanted fugitives. Brokering shadowy deals for criminals across the globe, Red was known by many as the \"Concierge of Crime.\" Now, he’s mysteriously surrendered to the FBI with an explosive offer: he will help catch the world’s most elusive criminals, under the condition that he speaks only to Elizabeth \"Liz\" Keen, an FBI profiler fresh out of Quantico. For Liz, it’s going to be one hell of a first day on the job.",
                   imagePath: "/9oAb7SlHybGK6P7dsOfEFjPsPBM.jpg", rawAirDate: "2013-09-23"),
            Season.create(context: testContext, id: 61357, seasonNumber: 2, episodeCount: 22, name: "Season 2",
                   overview: "For decades, ex-government agent Raymond \"Red\" Reddington has been one of the FBI's Most Wanted fugitives. He mysteriously surrendered to the FBI but now the FBI works for him as he identifies a \"blacklist\" of politicians, mobsters, spies and international terrorists. He will help catch them all... with the caveat that Elizabeth \"Liz\" Keen continues to work as his partner. Red will teach Liz to think like a criminal and \"see the bigger picture\"... whether she wants to or not.",
                   imagePath: "/b7o8AOpZPWJO8nP4SK8RRZ2d0B0.jpg", rawAirDate: "2014-09-22"),
            Season.create(context: testContext, id: 70935, seasonNumber: 3, episodeCount: 23, name: "Season 3",
                   overview: "Now a fugitive on the run, Liz must figure out how to protect herself from the fallout of her actions in the explosive season two finale.",
                   imagePath: "/hWN5imHrpg8wjEBsa7v80sGsS8r.jpg", rawAirDate: "2015-10-01"),
            Season.create(context: testContext, id: 80082, seasonNumber: 4, episodeCount: 22, name: "Season 4",
                   overview: "A mysterious man claiming to be Liz’s real father targets her, but first she must resolve the mystery of her lost childhood and reconcile her true identity with the elusive memories corrupted by Reddington. Without the truth, every day holds more danger for herself, her baby and her husband Tom. Meanwhile, the Task Force reels from Liz’s resurrection and friendships are fractured. Betrayed by those closest to him, Reddington’s specific moral code demands justice, all the while battling an army of new and unexpected blacklisters.",
                   imagePath: "/d5AJOxPzGkAHiaCHcESVCim1vHu.jpg", rawAirDate: "2016-09-22"),
            Season.create(context: testContext, id: 91328, seasonNumber: 5, episodeCount: 22, name: "Season 5",
                   overview: "Feeling surprisingly unencumbered, Raymond Reddington is back, and in the process of rebuilding his criminal empire. His lust for life is ever-present as he lays the foundation for this new enterprise - one that he\'ll design with Elizabeth Keen by his side. Living with the reality that Red is her father, Liz finds herself torn between her role as an FBI agent and the temptation to act on her more criminal instincts. In a world where the search for Blacklisters has become a family trade, Red will undoubtedly reclaim his moniker as the “Concierge of Crime.”",
                   imagePath: "/6MupSEjQbWd5t37iHoYNGV1Rp2Y.jpg", rawAirDate: "2017-09-27"),
            Season.create(context: testContext, id: 112279, seasonNumber: 6, episodeCount: 22, name: "Season 6",
                   overview: "Following the startling revelation that Raymond \"Red\" Reddington isn\'t who he says he is, Elizabeth Keen is torn between the relationship she\'s developed with the man assumed to be her father and her desire to get to the bottom of years of secrets and lies. Meanwhile, Red leads Liz and the FBI to some of the most strange and dangerous criminals yet, growing his empire and eliminating rivals in the process. All throughout, Liz and Red engage in an uneasy cat-and-mouse game in which lines will be crossed and the truth will be revealed.",
                   imagePath: "/f1R6R8AVS8EwaOUltlVxNjASZAs.jpg", rawAirDate: "2019-01-03"),
            Season.create(context: testContext, id: 132066, seasonNumber: 7, episodeCount: 19, name: "Season 7",
                   overview: "After being abducted by Katarina Rostova, Raymond \"Red\" Reddington finds himself alone in hostile territory, unsure of who, if anyone, he can trust. Surrounded by old enemies and new allies, Red must stay one step ahead of the Blacklist\'s most dangerous criminal, who will stop at nothing to unearth the very truth Red wants no one to know about. To find it, Katarina will insinuate herself into the life of Elizabeth Keen, who has finally reunited with her daughter Agnes. Katarina’s presence will bring danger to Liz’s doorstep and forever alter her relationship with Red.",
                   imagePath: "/e72ZZsSeKADafuy2aPWCUp15GgE.jpg", rawAirDate: "2019-10-04"),
            Season.create(context: testContext, id: 165869, seasonNumber: 8, episodeCount: 22, name: "Season 8", overview: "With his back against the wall, Raymond Reddington faces his most formidable enemy yet: Elizabeth Keen. Aligned with her mother, infamous Russian spy Katarina Rostova, Liz must decide how far she is willing to go to find out why Reddington has entered her life and what his endgame really is. The fallout between Reddington and Keen will have devastating consequences for all that lie in their wake, including the Task Force they helped to create.", imagePath: "/htJzeRcYI2ewMm4PTrg98UMXShe.jpg", rawAirDate: "2020-11-13"),
            Season.create(context: testContext, id: 200816, seasonNumber: 9, episodeCount: 22, name: "Season 9", overview: "In the two years following the death of Elizabeth Keen, Raymond Reddington and the members of the FBI Task Force have disbanded – their lives now changed in unexpected ways and with Reddington’s whereabouts unknown. Finding themselves each at a crossroads, a common purpose compels them to renew their original mission: to take down dangerous, vicious and eccentric Blacklisters. In the process, they begin to uncover lethal adversaries, unimaginable conspiracies and surprising betrayals that will threaten alliances and spur vengeance for the past, led by the most devious criminal of them all – Raymond Reddington.", imagePath: "/r935SMphvXppx5bJjbIBNx02fwc.jpg", rawAirDate: "2021-10-21")
        ]
        // swiftlint:enable vertical_parameter_alignment_on_call
        // swiftlint:enable multiline_arguments
        // swiftlint:enable multiline_arguments_brackets
        
        // Test, if the Decoding works
        let show: TMDBData = TestingUtils.load("Blacklist.json", mediaType: .show, into: testContext)
        XCTAssertEqual(show.id, 46952)
        XCTAssertEqual(show.title, "The Blacklist")
        XCTAssertEqual(show.originalTitle, "The Blacklist")
        XCTAssertEqual(show.imagePath, "/htJzeRcYI2ewMm4PTrg98UMXShe.jpg")
        assertEqual(show.genres, [Genre.create(context: testContext, id: 18, name: "Drama"), Genre.create(context: testContext, id: 80, name: "Crime"), Genre.create(context: testContext, id: 9648, name: "Mystery")])
        XCTAssertEqual(show.overview, "Raymond \"Red\" Reddington, one of the FBI's most wanted fugitives, surrenders in person at FBI Headquarters in Washington, D.C. He claims that he and the FBI have the same interests: bringing down dangerous criminals and terrorists. In the last two decades, he's made a list of criminals and terrorists that matter the most but the FBI cannot find because it does not know they exist. Reddington calls this \"The Blacklist\". Reddington will co-operate, but insists that he will speak only to Elizabeth Keen, a rookie FBI profiler.")
        XCTAssertEqual(show.status, .returning)
        XCTAssertEqual(show.originalLanguage, "en")
        
        assertEqual(show.productionCompanies, companies)
        XCTAssertEqual(show.homepageURL, "http://www.nbc.com/the-blacklist")
        
        XCTAssertEqual(show.popularity, 404.498)
        XCTAssertEqual(show.voteAverage, 7.5)
        XCTAssertEqual(show.voteCount, 2338)
        
        // Show exclusive data
        let showData = try XCTUnwrap(show.showData)
        
        assertEqual(showData.firstAirDate, 2013, 09, 23)
        assertEqual(showData.lastAirDate, 2022, 04, 22)
        XCTAssertEqual(showData.numberOfSeasons, 9)
        XCTAssertEqual(showData.numberOfEpisodes, 196)
        XCTAssertEqual(showData.episodeRuntime, [43])
        XCTAssertEqual(showData.isInProduction, true)
        assertEqual(showData.seasons, seasons)
        XCTAssertEqual(showData.showType, .scripted)
        assertEqual(showData.networks, networks)
        
        // Translations, Keywords, Videos and Cast
        let keywords = ["terrorist", "fbi", "investigation", "criminal mastermind", "crime lord", "hidden identity", "criminal consultant"]
        // Only some translations
        let translations = ["Arabic", "Dutch", "Turkish", "Mandarin"]
        let videos = [
            Video.create(context: testContext, key: "SoT5JImB1H8", name: "The Blacklist - first scene - Reddington surrenders himself to the FBI [HD]", site: "YouTube", type: "Clip", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "-WYdUaK54fU", name: "Blacklist Season 1 - Trailer", site: "YouTube", type: "Trailer", resolution: 1080, language: "en", region: "US")
        ]
        // Just a few. Too many to write all down
        let cast = [
            CastMember.create(context: testContext, id: 222141, name: "Megan Boone", roleName: "Elizabeth Keen", imagePath: "/8SjSPu2IJQVvuM2rP0KPNmze6Dz.jpg"),
            CastMember.create(context: testContext, id: 13548, name: "James Spader", roleName: "Raymond \"Red\" Reddington", imagePath: "/uET0mbf2bMkUXbRb1Oxi8Qjqcw3.jpg"),
            CastMember.create(context: testContext, id: 144583, name: "Hisham Tawfiq", roleName: "Dembe Zuma", imagePath: "/go8XkwY6pbqfUDExs7o1U6O1r5u.jpg")
        ]
        
        assertEqual(show.keywords, keywords)
        assertContains(translations, in: show.translations)
        assertEqual(show.videos, videos)
        assertContains(cast, in: show.cast)
    }
    
    func testDecodeShowGameOfThrones() throws {
        let companies = [
            ProductionCompany.create(context: testContext, id: 76043, name: "Revolution Sun Studios", logoPath: "/9RO2vbQ67otPrBLXCaC8UMp3Qat.png", originCountry: "US"),
            ProductionCompany.create(context: testContext, id: 12525, name: "Television 360", logoPath: nil, originCountry: ""),
            ProductionCompany.create(context: testContext, id: 5820, name: "Generator Entertainment", logoPath: nil, originCountry: ""),
            ProductionCompany.create(context: testContext, id: 12526, name: "Bighead Littlehead", logoPath: nil, originCountry: "")
        ]
        let networks = [
            ProductionCompany.create(context: testContext, id: 49, name: "HBO", logoPath: "/tuomPhY2UtuPTqqFnKMVHvSb724.png", originCountry: "US")
        ]
        // swiftlint:disable multiline_arguments multiline_arguments_brackets
        let seasons = [
            Season.create(context: testContext, id: 3627, seasonNumber: 0, episodeCount: 227, name: "Specials",
                          overview: "",
                          imagePath: "/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg", rawAirDate: "2010-12-05"),
            Season.create(context: testContext, id: 3624, seasonNumber: 1, episodeCount: 10, name: "Season 1",
                          overview: "Trouble is brewing in the Seven Kingdoms of Westeros. For the driven inhabitants of this visionary world, control of Westeros' Iron Throne holds the lure of great power. But in a land where the seasons can last a lifetime, winter is coming...and beyond the Great Wall that protects them, an ancient evil has returned. In Season One, the story centers on three primary areas: the Stark and the Lannister families, whose designs on controlling the throne threaten a tenuous peace; the dragon princess Daenerys, heir to the former dynasty, who waits just over the Narrow Sea with her malevolent brother Viserys; and the Great Wall--a massive barrier of ice where a forgotten danger is stirring.",
                          imagePath: "/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg", rawAirDate: "2011-04-17"),
            Season.create(context: testContext, id: 3625, seasonNumber: 2, episodeCount: 10, name: "Season 2",
                          overview: "The cold winds of winter are rising in Westeros...war is coming...and five kings continue their savage quest for control of the all-powerful Iron Throne. With winter fast approaching, the coveted Iron Throne is occupied by the cruel Joffrey, counseled by his conniving mother Cersei and uncle Tyrion. But the Lannister hold on the Throne is under assault on many fronts. Meanwhile, a new leader is rising among the wildings outside the Great Wall, adding new perils for Jon Snow and the order of the Night's Watch.",
                          imagePath: "/5tuhCkqPOT20XPwwi9NhFnC1g9R.jpg", rawAirDate: "2012-04-01"),
            Season.create(context: testContext, id: 3626, seasonNumber: 3, episodeCount: 10, name: "Season 3",
                          overview: "Duplicity and treachery...nobility and honor...conquest and triumph...and, of course, dragons. In Season 3, family and loyalty are the overarching themes as many critical storylines from the first two seasons come to a brutal head. Meanwhile, the Lannisters maintain their hold on King's Landing, though stirrings in the North threaten to alter the balance of power; Robb Stark, King of the North, faces a major calamity as he tries to build on his victories; a massive army of wildlings led by Mance Rayder march for the Wall; and Daenerys Targaryen--reunited with her dragons--attempts to raise an army in her quest for the Iron Throne.",
                          imagePath: "/7d3vRgbmnrRQ39Qmzd66bQyY7Is.jpg", rawAirDate: "2013-03-31"),
            Season.create(context: testContext, id: 3628, seasonNumber: 4, episodeCount: 10, name: "Season 4",
                          overview: "The War of the Five Kings is drawing to a close, but new intrigues and plots are in motion, and the surviving factions must contend with enemies not only outside their ranks, but within.",
                          imagePath: "/dniQ7zw3mbLJkd1U0gdFEh4b24O.jpg", rawAirDate: "2014-04-06"),
            Season.create(context: testContext, id: 62090, seasonNumber: 5, episodeCount: 10, name: "Season 5",
                          overview: "The War of the Five Kings, once thought to be drawing to a close, is instead entering a new and more chaotic phase. Westeros is on the brink of collapse, and many are seizing what they can while the realm implodes, like a corpse making a feast for crows.",
                          imagePath: "/527sR9hNDcgVDKNUE3QYra95vP5.jpg", rawAirDate: "2015-04-12"),
            Season.create(context: testContext, id: 71881, seasonNumber: 6, episodeCount: 10, name: "Season 6",
                          overview: "Following the shocking developments at the conclusion of season five, survivors from all parts of Westeros and Essos regroup to press forward, inexorably, towards their uncertain individual fates. Familiar faces will forge new alliances to bolster their strategic chances at survival, while new characters will emerge to challenge the balance of power in the east, west, north and south.",
                          imagePath: "/zvYrzLMfPIenxoq2jFY4eExbRv8.jpg", rawAirDate: "2016-04-24"),
            Season.create(context: testContext, id: 81266, seasonNumber: 7, episodeCount: 7, name: "Season 7",
                          overview: "The long winter is here. And with it comes a convergence of armies and attitudes that have been brewing for years.",
                          imagePath: "/3dqzU3F3dZpAripEx9kRnijXbOj.jpg", rawAirDate: "2017-07-16"),
            Season.create(context: testContext, id: 107971, seasonNumber: 8, episodeCount: 6, name: "Season 8",
                          overview: "The Great War has come, the Wall has fallen and the Night King's army of the dead marches towards Westeros. The end is here, but who will take the Iron Throne?",
                          imagePath: "/3OcQhbrecf4F4pYss2gSirTGPvD.jpg", rawAirDate: "2019-04-14")
        ]
        // swiftlint:enable multiline_arguments multiline_arguments_brackets
        
        // Test, if the Decoding works
        let show: TMDBData = TestingUtils.load("GameOfThrones.json", mediaType: .show, into: testContext)
        XCTAssertEqual(show.id, 1399)
        XCTAssertEqual(show.title, "Game of Thrones")
        XCTAssertEqual(show.originalTitle, "Game of Thrones")
        XCTAssertEqual(show.imagePath, "/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg")
        assertEqual(show.genres, [
            Genre.create(context: testContext, id: 10765, name: "Sci-Fi & Fantasy"),
            Genre.create(context: testContext, id: 18, name: "Drama"),
            Genre.create(context: testContext, id: 10759, name: "Action & Adventure")
        ])
        XCTAssertEqual(show.overview, "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest north. Amidst the war, a neglected military order of misfits, the Night's Watch, is all that stands between the realms of men and icy horrors beyond.")
        XCTAssertEqual(show.status, .ended)
        XCTAssertEqual(show.originalLanguage, "en")
        
        assertEqual(show.productionCompanies, companies)
        XCTAssertEqual(show.homepageURL, "http://www.hbo.com/game-of-thrones")
        
        XCTAssertEqual(show.popularity, 544.922)
        XCTAssertEqual(show.voteAverage, 8.4)
        XCTAssertEqual(show.voteCount, 17731)
        
        // Show exclusive data
        let showData = try XCTUnwrap(show.showData)
        
        assertEqual(showData.firstAirDate, 2011, 04, 17)
        assertEqual(showData.lastAirDate, 2019, 05, 19)
        XCTAssertEqual(showData.numberOfSeasons, 8)
        XCTAssertEqual(showData.numberOfEpisodes, 73)
        XCTAssertEqual(showData.episodeRuntime, [60])
        XCTAssertEqual(showData.isInProduction, false)
        assertEqual(showData.seasons, seasons)
        XCTAssertEqual(showData.showType, .scripted)
        assertEqual(showData.networks, networks)
        
        // Translations, Keywords, Videos and Cast
        let keywords = ["based on novel or book", "kingdom", "dragon", "king", "intrigue", "fantasy world"]
        // Only some translations
        let translations = ["Arabic", "Belarusian", "Bulgarian", "Bosnian", "Cantonese", "Czech", "Danish", "German", "Greek", "English", "Esperanto", "Spanish", "Spanish", "Estonian", "Persian", "Finnish", "French", "French", "Hebrew", "Croatian", "Hungarian", "Indonesian", "Icelandic", "Italian", "Japanese", "Georgian", "Korean", "Letzeburgesch", "Lithuanian", "Latvian", "Malayalam", "Dutch", "Norwegian", "Polish", "Portuguese", "Portuguese", "Romanian", "Russian", "Slovak", "Somali", "Serbian", "Swedish", "Tamil", "Thai", "Turkish", "Twi", "Ukrainian", "Uzbek", "Vietnamese", "Mandarin", "Mandarin", "Mandarin"]
        let videos = [
            Video.create(context: testContext, key: "y2ZJ3lTaREY", name: "Inside Game of Thrones: A Story in Camera Work – BTS (HBO)", site: "YouTube", type: "Behind the Scenes", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "f3MUpuRF6Ck", name: "Inside Game of Thrones: A Story in Prosthetics – BTS (HBO)", site: "YouTube", type: "Behind the Scenes", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "bjqEWgDVPe0", name: "GAME OF THRONES - SEASON 1- TRAILER", site: "YouTube", type: "Trailer", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "s7L2PVdrb_8", name: "Official Opening Credits: Game of Thrones (HBO)", site: "YouTube", type: "Opening Credits", resolution: 1080, language: "en", region: "US"),
            Video.create(context: testContext, key: "BpJYNVhGf1s", name: "Game of Thrones | Season 1 | Official Trailer", site: "YouTube", type: "Trailer", resolution: 1080, language: "en", region: "US")
        ]
        // Just a few. Too many to write all down
        let cast = [
            CastMember.create(context: testContext, id: 1223786, name: "Emilia Clarke", roleName: "Daenerys Targaryen", imagePath: "/86jeYFV40KctQMDQIWhJ5oviNGj.jpg"),
            CastMember.create(context: testContext, id: 964792, name: "Jacob Anderson", roleName: "Grey Worm", imagePath: "/i8dkNHSK3hok2VyvZwaVwFtcePh.jpg"),
            CastMember.create(context: testContext, id: 570296, name: "Joe Dempsie", roleName: "Gendry", imagePath: "/lnR0AMIwxQR6zUCOhp99GnMaRet.jpg")
        ]
        
        assertEqual(show.keywords, keywords)
        assertEqual(show.translations, translations)
        assertEqual(show.videos, videos)
        assertContains(cast, in: show.cast)
    }
}
