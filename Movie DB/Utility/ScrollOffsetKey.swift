// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

/// A preference key used to communicate the current scroll view offset up to its parent views
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
