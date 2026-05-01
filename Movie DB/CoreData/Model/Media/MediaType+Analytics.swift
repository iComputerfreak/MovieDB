// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics

extension MediaType {
    var analyticsValue: AnalyticsMediaType {
        switch self {
        case .movie:
            .movie
        case .show:
            .show
        }
    }
}
