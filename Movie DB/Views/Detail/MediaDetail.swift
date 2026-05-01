// Copyright © 2019 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct MediaDetail: View {
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                MediaDetailView()
            } else {
                MediaDetailLegacyView()
            }
        }
        .task {
            AnalyticsService.shared.track(.screenViewed(screenName: .mediaDetail))
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
