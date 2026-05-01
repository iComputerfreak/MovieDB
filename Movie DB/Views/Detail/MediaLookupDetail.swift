// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData
import SwiftUI
import os.log

struct MediaLookupDetail: View {
    private enum LoadingState {
        case loading
        case loaded(Media)
        case error(Error)
    }

    let tmdbID: Int
    let mediaType: MediaType
    let showingDismissButton: Bool

    private let localContext: NSManagedObjectContext

    @State private var state: LoadingState = .loading
    @State private var loadTaskID = UUID()

    init(tmdbID: Int, mediaType: MediaType, showingDismissButton: Bool = false) {
        localContext = PersistenceController.createDisposableViewContext()
        self.tmdbID = tmdbID
        self.mediaType = mediaType
        self.showingDismissButton = showingDismissButton
    }

    var body: some View {
        Group {
            switch state {
            case .loading:
                ScreenLoadingView(title: Strings.Generic.navBarLoadingTitle)
            case let .loaded(media):
                if #available(iOS 26.0, *) {
                    MediaLookupDetailView(showingDismissButton: showingDismissButton)
                        .environmentObject(media)
                } else {
                    LegacyMediaLookupDetailView(showingDismissButton: showingDismissButton)
                        .environmentObject(media)
                }
            case let .error(error):
                ScreenUnavailableView(
                    title: Strings.Lookup.Alert.errorLoadingTitle,
                    systemImage: "exclamationmark.triangle",
                    error: error,
                    actionTitle: Strings.Generic.retryLoading,
                    action: retryLoading
                )
            }
        }
        .task(id: loadTaskID, priority: .userInitiated) {
            await loadMedia()
        }
    }

    private func loadMedia() async {
        do {
            let media = try await TMDBAPI.shared.media(for: tmdbID, type: mediaType, context: localContext)
            await MainActor.run {
                state = .loaded(media)
            }
        } catch {
            Logger.api.error("Error loading media for lookup: \(error, privacy: .public)")
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    private func retryLoading() {
        state = .loading
        loadTaskID = UUID()
    }
}

#Preview {
    MediaLookupDetail(tmdbID: 603, mediaType: .movie)
        .previewEnvironment()
}

#Preview("Error") {
    MediaLookupDetail(tmdbID: 1, mediaType: .movie)
        .previewEnvironment()
}
