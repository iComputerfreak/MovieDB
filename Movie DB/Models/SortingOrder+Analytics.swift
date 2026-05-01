// Copyright © 2026 Jonas Frey. All rights reserved.

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
