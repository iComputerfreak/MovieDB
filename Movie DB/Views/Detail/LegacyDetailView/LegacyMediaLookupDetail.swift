// Copyright © 2022 Jonas Frey. All rights reserved.

import SwiftUI

@available(*, deprecated, renamed: "MediaLookupDetail", message: "Use the iOS 26+ variant with a fallback.")
struct LegacyMediaLookupDetailView: View {
    let showingDismissButton: Bool

    @EnvironmentObject private var mediaObject: Media

    var body: some View {
        NavigationStack {
            List {
                LegacyTitleView(media: mediaObject)
                LegacyBasicInfo()
                LegacyWatchProvidersInfo()
                LegacyTrailersView()
                LegacyExtendedInfo()
            }
            .groupedListStyle()
            .navigationTitle(mediaObject.title)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    AddMediaButton(tmdbID: mediaObject.tmdbID, mediaType: mediaObject.type)
                }
                if showingDismissButton {
                    ToolbarItem(placement: .secondaryAction) {
                        DismissButton()
                    }
                }
            }
        }
    }
}

#Preview {
    LegacyMediaLookupDetailView(showingDismissButton: false)
        .environmentObject(PlaceholderData.preview.staticMovie as Media)
        .previewEnvironment()
}
