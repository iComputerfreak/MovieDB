//
//  SortingOrder.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

enum SortingOrder: String, Equatable, CaseIterable {
    // TODO: Remove raw values completely? Should only ever use .localized
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
            return Strings.SortingOrder.name
        case .created:
            return Strings.SortingOrder.created
        case .releaseDate:
            return Strings.SortingOrder.releaseDate
        case .rating:
            return Strings.SortingOrder.rating
        }
    }
}

enum SortingDirection: String, Equatable {
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
