// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct FlatrateWatchProvidersLabel: View {
    let watchProviders: Set<WatchProvider>

    private var flatrateWatchProviders: [WatchProvider] {
        watchProviders
            .filter(where: \.type, isNotEqualTo: .buy)
            .filter(where: \.isHidden, isEqualTo: false)
            .removingDuplicates(key: \.id)
            .sorted(on: \.priority, by: <)
    }

    var body: some View {
        if flatrateWatchProviders.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: 0) {
                ForEach(flatrateWatchProviders, id: \.id) { provider in
                    ProviderView(
                        provider: provider,
                        iconSize: JFLiterals.watchProviderSubtitleIconSize,
                        showTypeLabel: false
                    )
                }
            }
        }
    }
}

#Preview {
    List {
        LibraryRow(subtitleContent: .flatrateWatchProviders)
    }
    .previewEnvironment()
}
