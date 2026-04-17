// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TrailersSection: View {
    @EnvironmentObject private var mediaObject: Media

    private var trailers: [Video] {
        mediaObject
            .videos
            .filter { $0.type == JFLiterals.trailerVideoType }
            // Only use trailers we can build a valid URL for
            .filter { $0.videoURL != nil }
            // Sort to make it consistent
            .sorted(on: \.key, by: <)
    }

    var body: some View {
        GroupBoxSection(title: Strings.Detail.trailersSectionHeader) {
            if trailers.isEmpty {
                HStack {
                    Spacer()
                    Text(Strings.Detail.trailersNoneAvailable)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(trailers, id: \.key) { video in
                            TrailerCardView(video: video)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 3)
            }
        }
    }
}

#Preview {
    NavigationStack {
        VStack(alignment: .leading) {
            TrailersSection()
                .padding(16)
            Spacer()
        }
    }
    .previewEnvironment()
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}
