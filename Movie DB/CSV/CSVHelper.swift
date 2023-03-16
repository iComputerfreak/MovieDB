//
//  CSVHelper.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

enum CSVHelper {
    static let delimiter: Character = ";"
    static let arraySeparator: Character = ","
    static let lineSeparator: Character = "\n"
    
    /// The `DateFormatter` used for de- and encoding dates
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// The `ISO8601DateFormatter` used for de- and encoding date-times
    static let dateTimeFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.timeZone = .utc
        return f
    }()
    
    // MARK: Import/Export Keys
    
    typealias Converter = (Any) -> String
    
    /// The CSV keys that are required to be present when importing media
    static let requiredImportKeys: [CSVKey] = [.tmdbID, .mediaType]
    /// The CSV keys that are optional when importing media
    static let optionalImportKeys: [CSVKey] = [
        .personalRating, .watchAgain, .tags, .notes, .movieWatched, .lastSeasonWatched, .lastEpisodeWatched,
        .creationDate, .modificationDate,
    ]
    // swiftlint:enable multiline_literal_brackets
    /// The properties/CSV keys that will be included in the export CSV data (do not include the legacy `showWatched` key)
    static let exportKeys: [CSVKey] = CSVKey.allCases.filter { $0 != .showWatched }
    
    // MARK: Export KeyPaths
    // swiftlint:disable force_cast
    /// Contains the corresponding key paths for all Media `CSVKey`s and an optional converter closure to convert the value to String
    static let exportKeyPaths: [CSVKey: (PartialKeyPath<Media>, Converter?)] = [
        .tmdbID: (\Media.tmdbID, nil),
        .mediaType: (\Media.type, { ($0 as! MediaType).rawValue }),
        .personalRating: (\Media.personalRating, { String(($0 as! StarRating).integerRepresentation) }),
        .watchAgain: (\Media.watchAgain, nil),
        .tags: (\Media.tags, { ($0 as! Set<Tag>).map(\.name).sorted().joined(separator: arraySeparator) }),
        .notes: (\Media.notes, nil),
        .creationDate: (\Media.creationDate, { dateTimeFormatter.string(from: $0 as! Date) }),
        .modificationDate: (\Media.modificationDate, { dateTimeFormatter.string(from: $0 as! Date) }),
        
        .id: (\Media.id as KeyPath<Media, UUID?>, { ($0 as! UUID).uuidString }),
        .title: (\Media.title, nil),
        .originalTitle: (\Media.originalTitle, nil),
        .genres: (\Media.genres, { ($0 as! Set<Genre>).map(\.name).sorted().joined(separator: arraySeparator) }),
        .overview: (\Media.overview, nil),
        .status: (\Media.status, { ($0 as! MediaStatus).rawValue }),
        .tagline: (\Media.tagline, nil),
    ]
    static let movieExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Movie>, Converter?)] = [
        .movieWatched: (\Movie.watched, { ($0 as! MovieWatchState).rawValue }),
        
        .releaseDate: (\Movie.releaseDate, { dateFormatter.string(from: $0 as! Date) }),
        .runtime: (\Movie.runtime, nil),
        .revenue: (\Movie.revenue, nil),
        .budget: (\Movie.budget, nil),
        .isAdult: (\Movie.isAdult, nil),
    ]
    static let showExclusiveExportKeyPaths: [CSVKey: (PartialKeyPath<Show>, Converter?)] = [
        .lastSeasonWatched: (\Show.watched, { ($0 as! ShowWatchState).season.description }),
        .lastEpisodeWatched: (\Show.watched, { ($0 as! ShowWatchState).episode?.description ?? "" }),
        
        .firstAirDate: (\Show.firstAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .lastAirDate: (\Show.lastAirDate, { dateFormatter.string(from: $0 as! Date) }),
        .numberOfSeasons: (\Show.numberOfSeasons, nil),
        .isInProduction: (\Show.isInProduction, nil),
        .showType: (\Show.showType, { ($0 as! ShowType).rawValue }),
        .createdBy: (\Show.createdBy, { ($0 as! [String]).sorted().joined(separator: arraySeparator) }),
    ]
    // swiftlint:enable force_cast
}
