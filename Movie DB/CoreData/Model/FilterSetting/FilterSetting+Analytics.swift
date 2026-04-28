//
//  FilterSetting+Analytics.swift
//  Movie DB
//
//  Created by OpenCode on 27.04.26.
//

import Analytics

extension FilterSetting {
    var analyticsFilterTypes: [AnalyticsFilterType] {
        let activeTypes: [AnalyticsFilterType] = [
            isAdult != nil ? AnalyticsFilterType.adult : nil,
            mediaType != nil ? AnalyticsFilterType.mediaType : nil,
            genres.isEmpty ? nil : AnalyticsFilterType.genre,
            rating != nil ? .rating : nil,
            year != nil ? .year : nil,
            statuses.isEmpty ? nil : AnalyticsFilterType.status,
            showTypes.isEmpty ? nil : AnalyticsFilterType.showType,
            numberOfSeasons != nil ? .numberOfSeasons : nil,
            watched != nil ? .watchState : nil,
            watchAgain != nil ? .watchAgain : nil,
            tags.isEmpty ? nil : AnalyticsFilterType.tag,
            watchProviders.isEmpty ? nil : AnalyticsFilterType.watchProvider,
        ].compactMap { $0 }

        return activeTypes.isEmpty ? [.unconfigured] : activeTypes
    }

    var analyticsPrimaryFilterType: AnalyticsFilterType {
        let activeTypes = analyticsFilterTypes.filter { $0 != .unconfigured }
        return switch activeTypes.count {
        case 0:
            .unconfigured
        case 1:
            activeTypes[0]
        default:
            .compound
        }
    }
}
