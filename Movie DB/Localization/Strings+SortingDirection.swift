//
//  Strings+SortingDirection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum SortingDirection {
        static let ascending = String(
            localized: "sortingDirection.ascending",
            comment: "A type of sorting direction (ascending or descending)"
        )
        static let descending = String(
            localized: "sortingDirection.descending",
            comment: "A type of sorting direction (ascending or descending)"
        )
    }
}

