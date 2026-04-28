//
//  AnalyticsEvent.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

public enum AnalyticsEvent: Sendable {
    case mediaAdded(mediaType: AnalyticsMediaType)
    case mediaAddFailedProLimit(mediaType: AnalyticsMediaType)
    case mediaDeleted(mediaType: AnalyticsMediaType)
    case watchlistToggled(newValue: Bool)
    case favoriteToggled(newValue: Bool)
    case boughtPro(productID: AnalyticsProductID, price: Double)
    case restoredPro
    case mediaExported(exportCountBucket: AnalyticsCountBucket)
    case mediaImported(importCountBucket: AnalyticsCountBucket, durationSeconds: Int, errorCount: Int)
    case mediaImportAborted(importCountBucket: AnalyticsCountBucket, durationSeconds: Int, errorCount: Int)
    case libraryReset
    case watchStateChanged
    case personalRatingChanged
    case libraryUpdate(result: AnalyticsOperationResult)
    case libraryReload
    case tagsImported(importCountBucket: AnalyticsCountBucket, durationSeconds: Int, errorCount: Int)
    case tagsExported(exportCountBucket: AnalyticsCountBucket)
    case screenViewed(screenName: AnalyticsScreenName)
    case customListCreated
    case dynamicListCreated(predicateType: AnalyticsFilterType)
    case customListDeleted
    case dynamicListDeleted(predicateType: AnalyticsFilterType)
    case libraryHomeFilterApplied(filterTypes: [AnalyticsFilterType])
    case librarySearched(resultCountBucket: AnalyticsResultCountBucket)
    case settingChanged(settingKey: AnalyticsSettingKey, newValue: AnalyticsSettingValue)
    case libraryHomeSortingChanged(sortingOrder: AnalyticsSortingOrder, sortingDirection: AnalyticsSortingDirection)
    case libraryHomeMultiselect(action: AnalyticsLibraryHomeMultiselectAction)
    case detailMenuActionUsed(action: AnalyticsDetailMenuAction)
    case libraryMultiselectActionUsed(action: AnalyticsLibraryMultiselectAction)
    case mediaContextMenuActionUsed(action: AnalyticsMediaContextMenuAction)
    case mediaSwipeActionUsed(action: AnalyticsMediaSwipeAction)
    case mediaShared(shareTargetType: AnalyticsShareTargetType)
}

extension AnalyticsEvent {
    var name: String {
        switch self {
        case .mediaAdded:
            "media_added"
        case .mediaAddFailedProLimit:
            "media_add_failed_pro_limit"
        case .mediaDeleted:
            "media_deleted"
        case .watchlistToggled:
            "watchlist_toggled"
        case .favoriteToggled:
            "favorite_toggled"
        case .boughtPro:
            "bought_pro"
        case .restoredPro:
            "restored_pro"
        case .mediaExported:
            "media_exported"
        case .mediaImported:
            "media_imported"
        case .mediaImportAborted:
            "media_import_aborted"
        case .libraryReset:
            "library_reset"
        case .watchStateChanged:
            "watch_state_changed"
        case .personalRatingChanged:
            "personal_rating_changed"
        case .libraryUpdate:
            "library_update"
        case .libraryReload:
            "library_reload"
        case .tagsImported:
            "tags_imported"
        case .tagsExported:
            "tags_exported"
        case .screenViewed:
            "screen_viewed"
        case .customListCreated:
            "custom_list_created"
        case .dynamicListCreated:
            "dynamic_list_created"
        case .customListDeleted:
            "custom_list_deleted"
        case .dynamicListDeleted:
            "dynamic_list_deleted"
        case .libraryHomeFilterApplied:
            "library_home_filter_applied"
        case .librarySearched:
            "library_searched"
        case .settingChanged:
            "setting_changed"
        case .libraryHomeSortingChanged:
            "library_home_sorting_changed"
        case .libraryHomeMultiselect:
            "library_home_multiselect"
        case .detailMenuActionUsed:
            "detail_menu_action_used"
        case .libraryMultiselectActionUsed:
            "library_multiselect_action_used"
        case .mediaContextMenuActionUsed:
            "media_context_menu_action_used"
        case .mediaSwipeActionUsed:
            "media_swipe_action_used"
        case .mediaShared:
            "media_shared"
        }
    }

    var properties: [String: Any]? {
        switch self {
        case let .mediaAdded(mediaType), let .mediaAddFailedProLimit(mediaType), let .mediaDeleted(mediaType):
            ["media_type": mediaType.rawValue]
        case let .watchlistToggled(newValue), let .favoriteToggled(newValue):
            ["new_value": newValue]
        case let .boughtPro(productID, price):
            [
                "product_id": productID.rawValue,
                "price": price,
            ]
        case .restoredPro:
            nil
        case let .mediaExported(exportCountBucket):
            ["export_count_bucket": exportCountBucket.rawValue]
        case let .mediaImported(importCountBucket, durationSeconds, errorCount):
            [
                "import_count_bucket": importCountBucket.rawValue,
                "duration_seconds": max(durationSeconds, 0),
                "error_count": max(errorCount, 0),
            ]
        case let .mediaImportAborted(importCountBucket, durationSeconds, errorCount),
            let .tagsImported(importCountBucket, durationSeconds, errorCount):
            [
                "import_count_bucket": importCountBucket.rawValue,
                "duration_seconds": max(durationSeconds, 0),
                "error_count": max(errorCount, 0),
            ]
        case .libraryReset, .watchStateChanged, .personalRatingChanged, .libraryReload, .customListCreated, .customListDeleted:
            nil
        case let .libraryUpdate(result):
            ["result": result.rawValue]
        case let .tagsExported(exportCountBucket):
            ["export_count_bucket": exportCountBucket.rawValue]
        case let .screenViewed(screenName):
            ["screen_name": screenName.rawValue]
        case let .dynamicListCreated(predicateType), let .dynamicListDeleted(predicateType):
            ["predicate_type": predicateType.rawValue]
        case let .libraryHomeFilterApplied(filterTypes):
            ["filter_types": filterTypes.map(\.rawValue).sorted()]
        case let .librarySearched(resultCountBucket):
            ["result_count_bucket": resultCountBucket.rawValue]
        case let .settingChanged(settingKey, newValue):
            [
                "setting_key": settingKey.rawValue,
                "new_value": newValue.value,
            ]
        case let .libraryHomeSortingChanged(sortingOrder, sortingDirection):
            [
                "sorting_order": sortingOrder.rawValue,
                "sorting_direction": sortingDirection.rawValue,
            ]
        case let .libraryHomeMultiselect(action):
            ["action": action.rawValue]
        case let .detailMenuActionUsed(action):
            ["action": action.rawValue]
        case let .libraryMultiselectActionUsed(action):
            ["action": action.rawValue]
        case let .mediaContextMenuActionUsed(action):
            ["action": action.rawValue]
        case let .mediaSwipeActionUsed(action):
            ["action": action.rawValue]
        case let .mediaShared(shareTargetType):
            ["share_target_type": shareTargetType.rawValue]
        }
    }
}
