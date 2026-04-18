// Copyright © 2026 Jonas Frey. All rights reserved.

import os.log
import SwiftUI
import UIKit

struct SeasonsDetailView: View {
    enum PreviewState {
        case loading
        case empty
    }

    @EnvironmentObject private var mediaObject: Media

    private let previewState: PreviewState?

    @State private var seasonThumbnails: [Int: UIImage?] = [:]
    @State private var isLoading = false
    @State private var loadTaskID = UUID()

    // swiftlint:disable:next force_cast
    private var show: Show { mediaObject as! Show }

    init(previewState: PreviewState? = nil) {
        self.previewState = previewState
    }

    var body: some View {
        Group {
            if mediaObject.isFault {
                EmptyView()
            } else if previewState == .loading || isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(Strings.Generic.loadingText)
                }
            } else if previewState == .empty || show.seasons.isEmpty {
                ContentUnavailableView {
                    Label(Strings.Detail.seasonsUnavailableTitle, systemImage: "list.number")
                } description: {
                    Text(Strings.Detail.seasonsUnavailableDescription)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(show.seasons.sorted(on: \.seasonNumber, by: <)) { (season: Season) in
                        if let overview = season.overview, !overview.isEmpty {
                            NavigationLink {
                                ScrollView {
                                    Text(overview)
                                        .padding()
                                        .navigationTitle(season.name)
                                }
                            } label: {
                                SeasonCardView(
                                    season: season,
                                    thumbnail: $seasonThumbnails[season.id]
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            SeasonCardView(
                                season: season,
                                thumbnail: $seasonThumbnails[season.id]
                            )
                        }
                    }
                }
                .padding(16)
                }
            }
        }
        .task(id: loadTaskID) {
            await loadSeasonThumbnails()
        }
        .navigationTitle(Strings.Detail.seasonsInfoNavBarTitle)
    }

    private func loadSeasonThumbnails() async {
        guard previewState == nil, seasonThumbnails.isEmpty else { return }
        guard let show = mediaObject as? Show, !show.seasons.isEmpty else { return }

        await MainActor.run {
            isLoading = true
        }

        Logger.detail.info(
            // swiftlint:disable:next line_length
            "Loading season thumbnails for \(show.title, privacy: .public) (mediaID: \(show.id?.uuidString ?? "nil", privacy: .public))"
        )

        // We don't use a throwing task group, since we want to fail silently.
        // Unavailable images should just not be loaded instead of showing an error message.
        let images: [Int: UIImage] = await withTaskGroup(of: (Int, UIImage?).self) { group in
            for season in show.seasons {
                _ = group.addTaskUnlessCancelled {
                    guard let imagePath = season.imagePath else {
                        return (0, nil)
                    }
                    return await (
                        season.id,
                        try? Utils.loadImage(with: imagePath, size: JFLiterals.thumbnailTMDBSize)
                    )
                }
            }

            var results: [Int: UIImage] = [:]
            for await (seasonID, image) in group {
                guard let image else { continue }
                results[seasonID] = image
            }

            return results
        }

        await MainActor.run {
            seasonThumbnails = images
            isLoading = false
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        SeasonsDetailView()
            .environmentObject(PlaceholderData.preview.createStaticShow() as Media)
            .previewEnvironment()
    }
}

#Preview("Loading") {
    NavigationStack {
        SeasonsDetailView(previewState: .loading)
            .environmentObject(PlaceholderData.preview.createStaticShow() as Media)
            .previewEnvironment()
    }
}

#Preview("Empty") {
    NavigationStack {
        SeasonsDetailView(previewState: .empty)
            .environmentObject(SeasonsDetailView.previewEmptyShow)
    }
    .previewEnvironment()
}

private extension SeasonsDetailView {
    static var previewEmptyShow: Media {
        let show = PlaceholderData.preview.createStaticShow()
        show.seasons = []
        return show as Media
    }
}
