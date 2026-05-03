// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct WatchProvidersSection: View {
    @EnvironmentObject private var mediaObject: Media

    private let columns = [GridItem(.adaptive(minimum: 48, maximum: 64), spacing: 12)]

    private var providers: [WatchProvider] {
        mediaObject.watchProviders
            // Only show flatrate and ads providers
            .filter(where: \.type, isNotEqualTo: .buy)
            .filter(where: \.isHidden, isEqualTo: false)
            .removingDuplicates(key: \.id)
            .sorted(on: \.priority, by: <)
    }

    var body: some View {
        GroupBoxSection(title: Strings.Detail.watchProvidersSectionHeader) {
            if providers.isEmpty {
                HStack {
                    Spacer()
                    Text(Strings.Detail.watchProvidersNoneAvailable)
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                    ForEach(providers, id: \.id) { provider in
                        ProviderTileView(provider: provider)
                    }
                }
                .padding(.vertical, 4)
            }

            let attribution = try? AttributedString(markdown: Strings.Detail.watchProvidersAttribution)
            Text(attribution ?? AttributedString("Powered by JustWatch.com"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            WatchProvidersSection()
                .padding(16)
            Spacer()
        }
    }
    .previewEnvironment()
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Empty State") {
    NavigationStack {
        VStack(alignment: .leading) {
            WatchProvidersSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject({
        let movie: Media = PlaceholderData.preview.createStaticMovie()
        movie.watchProviders = []
        return movie
    }())
    .previewEnvironment()
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            WatchProvidersSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
    .previewEnvironment()
}
