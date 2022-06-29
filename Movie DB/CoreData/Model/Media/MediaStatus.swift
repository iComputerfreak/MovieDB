//
//  MediaStatus.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

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
            return Strings.MediaStatus.planned
        case .inProduction:
            return Strings.MediaStatus.inProduction
        case .canceled:
            return Strings.MediaStatus.canceled
        case .returning:
            return Strings.MediaStatus.returning
        case .pilot:
            return Strings.MediaStatus.pilot
        case .ended:
            return Strings.MediaStatus.ended
        case .rumored:
            return Strings.MediaStatus.rumored
        case .postProduction:
            return Strings.MediaStatus.postProduction
        case .released:
            return Strings.MediaStatus.released
        }
    }
}
