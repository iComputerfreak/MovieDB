//
//  SortingOrder+Analytics.swift
//  Movie DB
//
//  Created by OpenCode on 27.04.26.
//

import Analytics

extension SortingOrder {
    var analyticsValue: AnalyticsSortingOrder {
        switch self {
        case .name:
            .name
        case .created:
            .created
        case .releaseDate:
            .releaseDate
        case .rating:
            .rating
        case .watchDate:
            .watchDate
        }
    }
}

extension SortingDirection {
    var analyticsValue: AnalyticsSortingDirection {
        switch self {
        case .ascending:
            .ascending
        case .descending:
            .descending
        }
    }
}
