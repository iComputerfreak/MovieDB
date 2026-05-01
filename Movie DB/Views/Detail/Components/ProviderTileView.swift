// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct ProviderTileView: View {
    @ObservedObject var provider: WatchProvider

    var body: some View {
        VStack(spacing: 4) {
            LoadableImageView(source: .image(provider.logoImage))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .thumbnailStyle(cornerRadius: 12)

            Text(provider.name)
                .font(.caption2)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
