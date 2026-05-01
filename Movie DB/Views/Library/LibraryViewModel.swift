// Copyright © 2023 Jonas Frey. All rights reserved.

import Foundation
import SwiftUI

struct LibraryViewModel {
    enum ActiveSheet: Hashable, Identifiable {
        @available(*, deprecated, message: "Use UnifiedSearchView instead. Kept for the legacy add-media sheet flow.")
        case addMedia(initialSearchText: String)
        case filter
        
        var id: Int { hashValue }
    }
    
    var activeSheet: ActiveSheet?
    
    var sortingOrder: SortingOrder = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingOrder) {
            return SortingOrder(rawValue: rawValue) ?? .default
        }
        return .default
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingOrder.rawValue, forKey: JFLiterals.Keys.sortingOrder)
        }
    }

    var sortingDirection: SortingDirection = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingDirection) {
            return SortingDirection(rawValue: rawValue) ?? SortingOrder.default.defaultDirection
        }
        return SortingOrder.default.defaultDirection
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingDirection.rawValue, forKey: JFLiterals.Keys.sortingDirection)
        }
    }
}
