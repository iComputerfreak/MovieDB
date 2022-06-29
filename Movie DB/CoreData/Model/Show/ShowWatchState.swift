//
//  ShowWatchState.swift
//  Movie DB
//
//  Created by Jonas Frey on 15.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

public enum ShowWatchState: RawRepresentable, Equatable {
    case season(Int)
    case episode(season: Int, episode: Int)
    case notWatched
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case let .season(season):
            return "season,\(season)"
        case let .episode(season, episode):
            return "episode,\(season),\(episode)"
        case .notWatched:
            return "notWatched"
        }
    }
    
    var season: Int? {
        if case let .season(season) = self {
            return season
        } else if case let .episode(season, _) = self {
            return season
        }
        return nil
    }
    
    var episode: Int? {
        if case let .episode(_, episode) = self {
            return episode
        }
        return nil
    }
    
    init(season: Int, episode: Int?) {
        guard let episode, episode > 0 else {
            self = .season(season)
            return
        }
        self = .episode(season: season, episode: episode)
    }
    
    public init?(rawValue: String) {
        // Season
        if let seasonNumber = Self.matchSeason(rawValue) {
            self = .season(seasonNumber)
        } else if let (seasonNumber, episodeNumber) = Self.matchEpisode(rawValue) {
            self = .episode(season: seasonNumber, episode: episodeNumber)
        } else if Self.matchNotWatched(rawValue) {
            self = .notWatched
        } else {
            return nil
        }
    }
    
    private static func matchSeason(_ rawValue: String) -> Int? {
        if
            let match = rawValue.matches(of: /season, [0 - 9]+/).first,
            // Drop the first 7 characters ("season,")
            let seasonNumber = Int(rawValue[match.range].dropFirst(7))
        {
            return seasonNumber
        }
        return nil
    }
    
    private static func matchEpisode(_ rawValue: String) -> (Int, Int)? {
        if let match = rawValue.matches(of: /episode, [0 - 9]+, [0 - 9]+/).first {
            // Drop the first 8 characters ("episode,")
            let parameters = String(rawValue[match.range].dropFirst(8)).components(separatedBy: ",")
            guard parameters.count == 2 else {
                return nil
            }
            if
                let season = Int(parameters[0]),
                let episode = Int(parameters[1])
            {
                return (season, episode)
            }
        }
        return nil
    }
    
    private static func matchNotWatched(_ rawValue: String) -> Bool {
        !rawValue.matches(of: /notWatched/).isEmpty
    }
}
