// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct MediaDetailLegacyView: View {
    var body: some View {
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
