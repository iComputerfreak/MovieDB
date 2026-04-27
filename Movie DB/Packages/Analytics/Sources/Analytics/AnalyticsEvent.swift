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
    case libraryReset
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
        case .libraryReset:
            "library_reset"
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
        case .restoredPro, .libraryReset:
            nil
        case let .mediaExported(exportCountBucket):
            ["export_count_bucket": exportCountBucket.rawValue]
        case let .mediaImported(importCountBucket, durationSeconds, errorCount):
            [
                "import_count_bucket": importCountBucket.rawValue,
                "duration_seconds": max(durationSeconds, 0),
                "error_count": max(errorCount, 0),
            ]
        }
    }
}
