// Copyright © 2026 Jonas Frey. All rights reserved.

import os.log
import SwiftUI
import UIKit

struct SeasonsDetailView: View {
    enum PreviewState {
        case loaded
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

    init(previewState: PreviewState? = nil, previewThumbnails: [Int: UIImage?] = [:]) {
        self.previewState = previewState
        _seasonThumbnails = State(initialValue: previewThumbnails)
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
                ContentUnavailableView(
                    Strings.Detail.seasonsInfoNavBarTitle,
                    systemImage: "list.number"
                )
            } else {
                List {
                    ForEach(show.seasons.sorted(on: \.seasonNumber, by: <)) { (season: Season) in
                        if let overview = season.overview, !overview.isEmpty {
                            NavigationLink {
                                ScrollView {
                                    Text(overview)
                                        .padding()
                                        .navigationTitle(season.name)
                                }
                            } label: {
                                SeasonInfoRowView(
                                    season: season,
                                    thumbnail: $seasonThumbnails[season.id]
                                )
                            }
                        } else {
                            SeasonInfoRowView(
                                season: season,
                                thumbnail: $seasonThumbnails[season.id]
                            )
                        }
                    }
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
    SeasonsDetailView(previewState: .loaded)
        .environmentObject(PlaceholderData.preview.staticShow as Media)
        .previewEnvironment()
}

#Preview("Loading") {
    SeasonsDetailView(previewState: .loading)
        .environmentObject(PlaceholderData.preview.staticShow as Media)
        .previewEnvironment()
}

#Preview("Empty") {
    NavigationStack {
        SeasonsDetailView(previewState: .empty)
            .environmentObject(PlaceholderData.preview.staticShow as Media)
    }
    .previewEnvironment()
}
