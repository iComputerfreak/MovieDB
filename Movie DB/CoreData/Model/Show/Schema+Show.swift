// Copyright © 2023 Jonas Frey. All rights reserved.

extension Schema {
    enum Show: String, SchemaEntityKey {
        static let _entityName = "Show"
        
        // MARK: Attributes
        case createdBy
        case episodeRuntime
        case firstAirDate
        case isInProduction
        case lastAirDate
        case lastEpisodeToAir
        case lastEpisodeWatched
        case lastSeasonWatched
        case nextEpisodeToAir
        case numberOfEpisodes
        case numberOfSeasons
        case showType
        
        // MARK: Relationships
        case networks
        case seasons
    }
}
