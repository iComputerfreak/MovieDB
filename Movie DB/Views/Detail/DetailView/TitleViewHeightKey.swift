// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

/// A preference key that is used to communicate the height of the title content up to the detail view
struct TitleViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
