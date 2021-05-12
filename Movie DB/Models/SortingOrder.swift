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
    // TODO: More sorting options
    
    /// The default sorting order
    static var `default`: Self {
        return .created
    }
    
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
}

enum SortingDirection: String, Equatable {
    case ascending
    case descending
    
    mutating func toggle() {
        switch self {
        case .ascending:
            self = .descending
        case .descending:
            self = .ascending
        }
    }
}
