// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TrailersSection: View {
    @EnvironmentObject private var mediaObject: Media
    @State private var selectedTrailer: Video?

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
                        .font(.callout)
                        .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(trailers, id: \.key) { video in
                            TrailerCardView(video: video) {
                                selectedTrailer = video
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 3)
            }
        }
        .sheet(item: $selectedTrailer) { trailer in
            if let trailerURL = trailer.videoURL {
                SafariWebView(url: trailerURL)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    let movieWithoutTrailers: Media = {
        var movie = PlaceholderData.preview.createStaticMovie()
        movie.videos = []
        return movie
    }()

    NavigationStack {
        VStack(alignment: .leading) {
            TrailersSection()
                .previewEnvironment()
            TrailersSection()
                .environmentObject(movieWithoutTrailers)
            Spacer()
        }
        .padding(16)
    }
}
