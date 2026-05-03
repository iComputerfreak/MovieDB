// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

@available(iOS 26.0, *)
struct MediaLookupDetailView: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.colorScheme) private var colorScheme

    let showingDismissButton: Bool

    private var backgroundColor: Color {
        switch colorScheme {
        case .dark: return .black
        case .light: return .white
        @unknown default: return .white
        }
    }

    var body: some View {
        ParallaxHeaderContentView {
            LoadableImageView(source: .image(mediaObject.thumbnail), contentMode: .fit, alignment: .top)
                .aspectRatio(1 / 1.5, contentMode: .fit)
        } header: {
            MediaTitleView(showsUserSpecificFields: false)
        } content: {
            VStack(alignment: .leading) {
                BasicInfoSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                WatchProvidersSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                TrailersSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                ExtendedInfoSection()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
        }
        .scrollEdgeEffectHidden(for: .top)
        .navigationTitle("")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AddMediaButton(tmdbID: mediaObject.tmdbID, mediaType: mediaObject.type)
            }
            if showingDismissButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    DismissButton()
                }
            }
        }
        .task(priority: .userInitiated) {
            if mediaObject.thumbnail == nil {
                mediaObject.loadImages()
            }
        }
    }
}

@available(iOS 26.0, *)
#Preview("Movie") {
    NavigationStack {
        MediaLookupDetailView(showingDismissButton: false)
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

@available(iOS 26.0, *)
#Preview("Show") {
    NavigationStack {
        MediaLookupDetailView(showingDismissButton: true)
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}

@available(iOS 26.0, *)
#Preview("Minimal Movie") {
    NavigationStack {
        MediaLookupDetailView(showingDismissButton: true)
            .environmentObject(PlaceholderData.preview.staticMinimalMovie as Media)
            .previewEnvironment()
    }
}
