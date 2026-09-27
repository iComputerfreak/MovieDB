// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Contains enriched TMDB metadata used to refine an uncertain title-import match.
struct TitleImportCandidateDetails: Sendable {
    let alternativeTitles: [String]
    let directors: [String]
    let runtimeMinutes: Int?
}

// swiftlint:disable nesting
/// Decodes the combined movie or show details response requested for title-import enrichment.
struct TitleImportDetailsResponse: Decodable {
    let runtime: Int?
    let episodeRuntime: [Int]
    let createdBy: [Creator]
    let credits: Credits
    let alternativeTitles: AlternativeTitles

    var candidateDetails: TitleImportCandidateDetails {
        let crewDirectors = credits.crew.filter { $0.job == JFLiterals.directorJobString }.map(\.name)
        // TMDB exposes movie directors in credits, but show creators through created_by.
        return TitleImportCandidateDetails(
            alternativeTitles: alternativeTitles.results.compactMap { $0.title ?? $0.name },
            directors: crewDirectors.isEmpty ? createdBy.map(\.name) : crewDirectors,
            runtimeMinutes: runtime ?? episodeRuntime.first
        )
    }

    /// Decodes a show creator returned by TMDB.
    struct Creator: Decodable {
        let name: String
    }

    /// Decodes the crew credits used to identify movie directors.
    struct Credits: Decodable {
        let crew: [CrewMember]

        /// Creates a credits value from an already decoded crew.
        /// - Parameter crew: The crew members to expose.
        init(crew: [CrewMember]) {
            self.crew = crew
        }

        /// Decodes crew credits, treating a missing crew collection as empty.
        /// - Parameter decoder: The decoder containing the credits response.
        /// - Throws: A `DecodingError` when the crew value has an invalid representation.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            crew = try container.decodeIfPresent([CrewMember].self, forKey: .crew) ?? []
        }

        /// Maps the credits response keys used during decoding.
        private enum CodingKeys: String, CodingKey {
            case crew
        }
    }

    /// Decodes the name and job of one TMDB crew member.
    struct CrewMember: Decodable {
        let name: String
        let job: String?
    }

    /// Decodes the alternative-title collection returned by TMDB.
    struct AlternativeTitles: Decodable {
        let results: [AlternativeTitle]

        /// Creates an alternative-title collection from decoded results.
        /// - Parameter results: The alternative title records to expose.
        init(results: [AlternativeTitle]) {
            self.results = results
        }

        /// Decodes alternative titles, treating a missing results collection as empty.
        /// - Parameter decoder: The decoder containing the alternative-title response.
        /// - Throws: A `DecodingError` when the results value has an invalid representation.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            results = try container.decodeIfPresent([AlternativeTitle].self, forKey: .results) ?? []
        }

        /// Maps the alternative-title response keys used during decoding.
        private enum CodingKeys: String, CodingKey {
            case results
        }
    }

    /// Decodes a movie title or show name from an alternative-title record.
    struct AlternativeTitle: Decodable {
        let title: String?
        let name: String?
    }

    /// Decodes enrichment metadata from a combined TMDB details response.
    /// - Parameter decoder: The decoder containing the combined details response.
    /// - Throws: A `DecodingError` when any present response value has an invalid representation.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        episodeRuntime = try container.decodeIfPresent([Int].self, forKey: .episodeRuntime) ?? []
        createdBy = try container.decodeIfPresent([Creator].self, forKey: .createdBy) ?? []
        credits = try container.decodeIfPresent(Credits.self, forKey: .credits) ?? Credits(crew: [])
        alternativeTitles = try container.decodeIfPresent(AlternativeTitles.self, forKey: .alternativeTitles)
            ?? AlternativeTitles(results: [])
    }

    /// Maps movie and show detail keys into their shared enrichment representation.
    private enum CodingKeys: String, CodingKey {
        case runtime
        case episodeRuntime = "episode_run_time"
        case createdBy = "created_by"
        case credits
        case alternativeTitles = "alternative_titles"
    }
}
// swiftlint:enable nesting
