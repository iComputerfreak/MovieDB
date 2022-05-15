//
//  MediaStatus.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

/// Represents the status of a media (e.g. Planned, Rumored, Returning Series, Canceled)
public enum MediaStatus: String, Codable, CaseIterable, Hashable {
    // MARK: General
    case planned = "Planned"
    case inProduction = "In Production"
    case canceled = "Canceled"
    // MARK: Show Exclusive
    case returning = "Returning Series"
    case pilot = "Pilot"
    case ended = "Ended"
    // MARK: Movie Exclusive
    case rumored = "Rumored"
    case postProduction = "Post Production"
    case released = "Released"
    
    var localized: String {
        switch self {
        case .planned:
            return String(
                localized: "mediaStatus.planned",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .inProduction:
            return String(
                localized: "mediaStatus.inProduction",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .canceled:
            return String(
                localized: "mediaStatus.cancelled",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .returning:
            return String(
                localized: "mediaStatus.returning",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .pilot:
            return String(
                localized: "mediaStatus.pilot",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .ended:
            return String(
                localized: "mediaStatus.ended",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .rumored:
            return String(
                localized: "mediaStatus.rumored",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .postProduction:
            return String(
                localized: "mediaStatus.postProduction",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        case .released:
            return String(
                localized: "mediaStatus.released",
                comment: "The current status of a media (e.g. 'In Production')"
            )
        }
    }
}
