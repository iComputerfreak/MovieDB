//
//  MediaType+Analytics.swift
//  Movie DB
//
//  Created by OpenCode on 27.04.26.
//

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
