//
//  MediaLookupDetail.swift
//  Movie DB
//
//  Created by OpenCode on 30.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

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
    @State private var hasStartedLoading = false

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
                ProgressView()
                    .navigationTitle(Strings.Generic.navBarLoadingTitle)
            case let .loaded(media):
                Group {
                    if #available(iOS 26.0, *) {
                        MediaLookupDetailView(showingDismissButton: showingDismissButton)
                            .environmentObject(media)
                    } else {
                        LegacyMediaLookupDetailView(showingDismissButton: showingDismissButton)
                            .environmentObject(media)
                    }
                }
            case let .error(error):
                VStack {
                    Text(Strings.Lookup.errorLoadingMedia(error.localizedDescription))
                    Button(Strings.Generic.retryLoading) {
                        hasStartedLoading = false
                        state = .loading
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task(priority: .userInitiated) {
            guard !hasStartedLoading else { return }
            hasStartedLoading = true
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
}

#Preview {
    MediaLookupDetail(tmdbID: 603, mediaType: .movie)
        .previewEnvironment()
}
