//
//  ShowWatchState.swift
//  Movie DB
//
//  Created by Jonas Frey on 15.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents the watch state of a show
public enum ShowWatchState: WatchState, RawRepresentable, Equatable {
    /// A predicate that filters for all shows that have not been watched yet
    static let showsNotWatchedPredicate = NSPredicate(
        format: "type == %@ AND lastSeasonWatched == 0 AND (lastEpisodeWatched == nil OR lastEpisodeWatched == 0)",
        MediaType.show.rawValue
    )
    /// A predicate that filters for all shows that have been watched for at least one episode
    static let showsWatchedAnyPredicate = NSPredicate(
        format: "type == %@ AND lastSeasonWatched > 0",
        MediaType.show.rawValue
    )
    /// A predicate that filters for all shows that have been watched up to a specific episode (not counting shows that have been watched up to a specific season)
    static let showsWatchedEpisode = NSPredicate(
        format: "type == %@ AND lastSeasonWatched > 0 AND lastEpisodeWatched > 0",
        MediaType.show.rawValue
    )
    /// A predicate that filters for all shows that have been watched up to a specific season (and that season has been finished, i.e. all episodes of that season watched)
    static let showsWatchedSeason = NSPredicate(
        format: "type == %@ AND lastSeasonWatched > 0 AND (lastEpisodeWatched == nil OR lastEpisodeWatched == 0)",
        MediaType.show.rawValue
    )
    /// A predicate that filters for all shows that have an unknown watch state
    static let showsWatchedUnknown = NSPredicate(
        format: "type == %@ AND lastSeasonWatched == nil",
        MediaType.show.rawValue
    )
    
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
    
    /// Returns the season part of this watch state, or `0`, if the watch state is `.notWatched`
    var season: Int {
        switch self {
        case let .season(season):
            return season
        case let .episode(season, _):
            return season
        case .notWatched:
            // If the show is not watched, we return 0
            return 0
        }
    }
    
    /// Returns the episode part of this watch state, or `nil`, if the watch state is `.season` or `.notWatched`
    var episode: Int? {
        switch self {
        case let .episode(_, episode):
            return episode
        case .notWatched, .season:
            return nil
        }
    }
    
    /// Creates a new watch state from a given season and episode
    ///
    /// The watch state is constructed by the given rules:
    /// 1. If the season is `< 0`, the watch state will be constructed as `nil`, indicating an unknown watch state (as in the app does not know if the user has watched the show yet).
    /// 2. If the season is `== 0`, the watch state will be constructed as `.notWatched`.
    /// 3. If the season is `> 0` and the episode is `nil` or `<= 0`, the watch state will be constructed as `.season()`,
    /// describing a watch state where the user has watched up to a specific season and completed watching that season
    /// 4. If the season and episode both are `> 0`, the watch state is constructed as `.episode()`,
    /// describing a watch state where the user has watched up to a specific episode of a specific season
    ///
    /// - Parameters:
    ///   - season: The season up to which the user has watched, or `0` if the user has not watched the show yet, or `-1` if the state is unknown.
    ///   - episode: The episode up to which the user has watched (in the given season), or `nil`,
    ///   if the user watched the full season or has not watched the show yet.
    init?(season: Int, episode: Int?) {
        // Season numbers < 0 mean "unknown"
        guard season >= 0 else {
            return nil
        }
        guard season > 0 else {
            self = .notWatched
            return
        }
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
            let match = rawValue.matches(of: /season,[0-9]+/).first,
            // Drop the first 7 characters ("season,")
            let seasonNumber = Int(rawValue[match.range].dropFirst(7))
        {
            return seasonNumber
        }
        return nil
    }
    
    private static func matchEpisode(_ rawValue: String) -> (Int, Int)? {
        if let match = rawValue.matches(of: /episode,[0-9]+,[0-9]+/).first {
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
