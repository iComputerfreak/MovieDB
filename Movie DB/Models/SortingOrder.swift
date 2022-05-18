//
//  SortingOrder.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

enum SortingOrder: String, Equatable, CaseIterable {
    case name = "Name"
    case created = "Created"
    case releaseDate = "Release Date"
    case rating = "Rating"
    
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
            return String(
                localized: "sortingOrder.name",
                comment: "A type of sorting order (name, release date, ...)"
            )
        case .created:
            return String(
                localized: "sortingOrder.created",
                comment: "A type of sorting order (name, release date, ...)"
            )
        case .releaseDate:
            return String(
                localized: "sortingOrder.releaseDate",
                comment: "A type of sorting order (name, release date, ...)"
            )
        case .rating:
            return String(
                localized: "sortingOrder.rating",
                comment: "A type of sorting order (name, release date, ...)"
            )
        }
    }
}

enum SortingDirection: String, Equatable {
    case ascending
    case descending
    
    var localized: String {
        switch self {
        case .ascending:
            return String(
                localized: "sortingDirection.ascending",
                comment: "A type of sorting direction (ascending or descending)"
            )
        case .descending:
            return String(
                localized: "sortingDirection.descending",
                comment: "A type of sorting direction (ascending or descending)"
            )
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
