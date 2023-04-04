//
//  Strings+SortingOrder.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum SortingOrder {
        static let name = String(
            localized: "sortingOrder.name",
            comment: "A type of sorting order (name, release date, ...)"
        )
        static let created = String(
            localized: "sortingOrder.created",
            comment: "A type of sorting order (name, release date, ...)"
        )
        static let releaseDate = String(
            localized: "sortingOrder.releaseDate",
            comment: "A type of sorting order (name, release date, ...)"
        )
        static let rating = String(
            localized: "sortingOrder.rating",
            comment: "A type of sorting order (name, release date, ...)"
        )
    }
}
