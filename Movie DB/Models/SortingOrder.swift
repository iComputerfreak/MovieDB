//
//  SortingOrder.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

public enum SortingOrder: String, Equatable, CaseIterable, Codable {
    case name
    case created
    case releaseDate
    case rating
    
    /// The default sorting order
    static var `default`: Self { .created }
    
    var defaultDirection: SortingDirection {
        switch self {
        case .name:
            return .ascending
        case .created:
            return .descending
        case .releaseDate:
            return .descending
        case .rating:
            return .descending
        }
    }
    
    var localized: String {
        switch self {
        case .name:
            return Strings.SortingOrder.name
        case .created:
            return Strings.SortingOrder.created
        case .releaseDate:
            return Strings.SortingOrder.releaseDate
        case .rating:
            return Strings.SortingOrder.rating
        }
    }
    
    func createSortDescriptors(with direction: SortingDirection) -> [NSSortDescriptor] {
        var sortDescriptors = [NSSortDescriptor]()
        switch self {
        case .name:
            // Name sort descriptor gets appended at the end as a tie breaker
            break
        case .created:
            sortDescriptors.append(NSSortDescriptor(
                keyPath: \Media.creationDate,
                ascending: direction == .ascending
            ))
        case .releaseDate:
            sortDescriptors.append(NSSortDescriptor(
                key: "releaseDateOrFirstAired",
                ascending: direction == .ascending
            ))
        case .rating:
            sortDescriptors.append(NSSortDescriptor(
                key: "personalRating",
                ascending: direction == .ascending
            ))
        }
        // Append the name sort descriptor as a second alternative
        sortDescriptors.append(NSSortDescriptor(keyPath: \Media.title, ascending: direction == .ascending))
        return sortDescriptors
    }
}

public enum SortingDirection: String, Equatable, Codable {
    case ascending
    case descending
    
    var localized: String {
        switch self {
        case .ascending:
            return Strings.SortingDirection.ascending
        case .descending:
            return Strings.SortingDirection.descending
        }
    }
    
    mutating func toggle() {
        switch self {
        case .ascending:
            self = .descending
        case .descending:
            self = .ascending
        }
    }
}
