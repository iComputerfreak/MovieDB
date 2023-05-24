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
    
    func createNSSortDescriptors(with direction: SortingDirection) -> [NSSortDescriptor] {
        createSortDescriptors(with: direction) // .map(NSSortDescriptor.init)
    }
    
    func createSortDescriptors(with direction: SortingDirection) -> [NSSortDescriptor] {
        let ascending = direction == .ascending
        
        var sortDescriptors = [NSSortDescriptor]()
        switch self {
        case .name:
            // Name sort descriptor gets appended at the end as a tie breaker already
            break
        case .created:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Media.creationDate, ascending: ascending))
        case .releaseDate:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Media.releaseDateOrFirstAired, ascending: ascending))
        case .rating:
            // !!!: Using SortDescriptor<Media> here fails at runtime, because Media must be introspectable by the
            // !!!: objective-c runtime in order to use it as the base type of a `SortDescriptor` when using
            // !!!: Media.personalRating.integerRepresentation / .rawValue (just .personalRating does not work due to
            // !!!: SortDescriptor's initializers)
            sortDescriptors.append(NSSortDescriptor(keyPath: \Media.personalRating, ascending: ascending))
        }
        // Append the name sort descriptor as a second alternative
        sortDescriptors.append(NSSortDescriptor(keyPath: \Media.title, ascending: ascending))
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
