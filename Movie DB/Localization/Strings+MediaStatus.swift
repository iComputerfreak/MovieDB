//
//  Strings+MediaStatus.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum MediaStatus {
        static let planned = String(
            localized: "mediaStatus.planned",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let inProduction = String(
            localized: "mediaStatus.inProduction",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let canceled = String(
            localized: "mediaStatus.cancelled",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let returning = String(
            localized: "mediaStatus.returning",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let pilot = String(
            localized: "mediaStatus.pilot",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let ended = String(
            localized: "mediaStatus.ended",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let rumored = String(
            localized: "mediaStatus.rumored",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let postProduction = String(
            localized: "mediaStatus.postProduction",
            comment: "The current status of a media (e.g. 'In Production')"
        )
        static let released = String(
            localized: "mediaStatus.released",
            comment: "The current status of a media (e.g. 'In Production')"
        )
    }
}
