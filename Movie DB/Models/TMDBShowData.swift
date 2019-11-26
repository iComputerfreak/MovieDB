//
//  TMDBShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

struct TMDBShowData: TMDBData, Equatable {
    // Protocol properties
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var overview: String?
    var status: String
    var originalLanguage: String
    var imdbID: String?
    var productionCompanies: [ProductionCompany]
    var homepageURL: String?
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    var castWrapper: CastWrapper?
    var keywordsWrapper: KeywordsWrapper?
    var translationsWrapper: TranslationsWrapper?
    var videosWrapper: VideosWrapper?
    
    // Exclusive properties
    /// The raw first air date formatted as "yyyy-MM-dd"
    var rawFirstAirDate: String?
    /// The date, the show was first aired
    var firstAirDate: Date? { rawFirstAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawFirstAirDate!) }
    /// The raw last air date formatted as "yyyy-MM-dd"
    var rawLastAirDate: String?
    /// The date, the show was last aired
    var lastAirDate: Date? { rawLastAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawLastAirDate!) }
    /// The number of seasons the show  has
    var numberOfSeasons: Int
    /// The number of episodes, the show has
    var numberOfEpisodes: Int
    /// The runtime the episodes typically have
    var episodeRuntime: [Int]
    /// Whether the show is still in production
    var isInProduction: Bool
    /// The list of seasons the show has
    var seasons: [Season]
    /// The type of the show (e.g. Scripted)
    var type: String
    /// The list of networks that publish the show
    var networks: [ProductionCompany]
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title = "name"
        case originalTitle = "original_name"
        case imagePath = "poster_path"
        case genres = "genres"
        case overview
        case status
        case originalLanguage = "original_language"
        case imdbID = "imdb_id"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        
        // Exclusive Properties
        case rawFirstAirDate = "first_air_date"
        case rawLastAirDate = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case episodeRuntime = "episode_run_time"
        case isInProduction = "in_production"
        case seasons
        case type
        case networks
        
        // Filled externally by separate API calls
        //case keywordsWrapper, castWrapper, translationsWrapper, videosWrapper
    }
}


// MARK: - Property Structs

// This has to be a class for `self.thumbnail` to be changed in the loadThumbnail() function
/// Represents a season of a show
class Season: Codable, Hashable, Identifiable {
    /// The id of the season on TMDB
    var id: Int
    /// The number of the season
    var seasonNumber: Int
    /// The number of episodes, this season has
    var episodeCount: Int
    /// The name of the season
    var name: String
    /// A short description of the season
    var overview: String?
    /// A path to the poster image of the season on TMDB
    var imagePath: String?/* {
        didSet {
            loadThumbnail()
        }
    }*/
    /// The thumbnail of this season
    private(set) var thumbnail: UIImage? = nil
    /// The date when the season aired
    var rawAirDate: String?
    /// The date, the season aired
    var airDate: Date? { rawAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawAirDate!) }
    
    /*func loadThumbnail() {
        guard let imagePath = imagePath, !imagePath.isEmpty else {
            return
        }
        print("Loading thumbnail for \(name)")
        let urlString = JFUtils.getTMDBImageURL(path: imagePath)
        JFUtils.getRequest(urlString, parameters: [:]) { (data) in
            guard let data = data else {
                print("Unable to get image")
                return
            }
            // Update the thumbnail in the main thread
            DispatchQueue.main.async {
                self.thumbnail = UIImage(data: data)
            }
        }
    }*/
    
    static func == (lhs: Season, rhs: Season) -> Bool {
        return lhs.id == rhs.id &&
            lhs.seasonNumber == rhs.seasonNumber &&
            lhs.episodeCount == rhs.episodeCount &&
            lhs.name == rhs.name &&
            lhs.overview == rhs.overview &&
            lhs.imagePath == rhs.imagePath &&
            lhs.rawAirDate == rhs.rawAirDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(seasonNumber)
        hasher.combine(episodeCount)
        hasher.combine(name)
        hasher.combine(overview)
        hasher.combine(imagePath)
        hasher.combine(rawAirDate)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case name
        case overview
        case imagePath = "poster_path"
        case rawAirDate = "air_date"
    } 
}
