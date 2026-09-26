// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportCandidateDetails: Sendable {
    let alternativeTitles: [String]
    let directors: [String]
    let runtimeMinutes: Int?
}

// swiftlint:disable nesting
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

    struct Creator: Decodable {
        let name: String
    }

    struct Credits: Decodable {
        let crew: [CrewMember]

        init(crew: [CrewMember]) {
            self.crew = crew
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            crew = try container.decodeIfPresent([CrewMember].self, forKey: .crew) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case crew
        }
    }

    struct CrewMember: Decodable {
        let name: String
        let job: String?
    }

    struct AlternativeTitles: Decodable {
        let results: [AlternativeTitle]

        init(results: [AlternativeTitle]) {
            self.results = results
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            results = try container.decodeIfPresent([AlternativeTitle].self, forKey: .results) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case results
        }
    }

    struct AlternativeTitle: Decodable {
        let title: String?
        let name: String?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        episodeRuntime = try container.decodeIfPresent([Int].self, forKey: .episodeRuntime) ?? []
        createdBy = try container.decodeIfPresent([Creator].self, forKey: .createdBy) ?? []
        credits = try container.decodeIfPresent(Credits.self, forKey: .credits) ?? Credits(crew: [])
        alternativeTitles = try container.decodeIfPresent(AlternativeTitles.self, forKey: .alternativeTitles)
            ?? AlternativeTitles(results: [])
    }

    private enum CodingKeys: String, CodingKey {
        case runtime
        case episodeRuntime = "episode_run_time"
        case createdBy = "created_by"
        case credits
        case alternativeTitles = "alternative_titles"
    }
}
// swiftlint:enable nesting
