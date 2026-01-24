// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

@available(*, deprecated, renamed: "MediaDetail", message: "Use the iOS 26+ variant with a fallback.")
struct MediaDetailLegacyView: View {
    var body: some View {
        // TODO: Implement
        Text("TODO: Implement")
    }
}

#Preview("Movie") {
    NavigationStack {
        MediaDetailLegacyView()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaDetailLegacyView()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
