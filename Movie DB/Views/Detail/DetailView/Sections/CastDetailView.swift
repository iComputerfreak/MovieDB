// Copyright © 2026 Jonas Frey. All rights reserved.

import os.log
import SwiftUI

struct CastDetailView: View {
    enum PreviewState {
        case loading
        case empty
    }

    @EnvironmentObject private var mediaObject: Media

    private let previewState: PreviewState?

    @State private var cast: [CastMemberDummy] = []
    @State private var isLoading = false
    @State private var loadError: Error?
    @State private var loadTaskID = UUID()

    init(previewState: PreviewState? = nil) {
        self.previewState = previewState
    }

    var body: some View {
        Group {
            if mediaObject.isFault {
                EmptyView()
            } else if previewState == .loading || isLoading {
                ScreenLoadingView()
            } else if let loadError {
                ScreenUnavailableView(
                    title: Strings.Detail.Alert.errorLoadingCastTitle,
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    error: loadError,
                    actionTitle: Strings.Generic.retryLoading,
                    action: retryLoading
                )
            } else if previewState == .empty || cast.isEmpty {
                ScreenUnavailableView(
                    title: Strings.Detail.castNoneAvailable,
                    systemImage: "person.3.sequence.fill"
                )
            } else {
                List {
                    ForEach(cast) { member in
                        CastMemberRow(castMember: member)
                    }
                }
            }
        }
        .task(id: loadTaskID) {
            await loadCast()
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(Strings.Detail.castLabel)
    }

    @MainActor
    private func loadCast() async {
        guard previewState == nil, cast.isEmpty else { return }
        guard !mediaObject.isFault else { return }

        isLoading = true
        loadError = nil

        let mediaID = mediaObject.id?.uuidString ?? "nil"

        Logger.api.info(
            "Loading cast for \(mediaObject.title, privacy: .public) (mediaID: \(mediaID, privacy: .public))"
        )

        do {
            cast = try await TMDBAPI.shared.cast(for: mediaObject.tmdbID, type: mediaObject.type)
        } catch {
            Logger.api.error(
                "Error loading cast for \(mediaObject.title, privacy: .public): \(error, privacy: .public)"
            )
            cast = []
            loadError = error
        }

        isLoading = false
    }

    private func retryLoading() {
        loadTaskID = UUID()
    }
}

#Preview("Live") {
    CastDetailView()
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Loading") {
    CastDetailView(previewState: .loading)
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Empty") {
    CastDetailView(previewState: .empty)
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie as Media)
}
