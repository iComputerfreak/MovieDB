//
//  MediaLookupDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct MediaLookupDetail: View {
    enum LoadingState {
        case loading
        case loaded(Media)
        case error(Error)
    }
    
    let tmdbID: Int
    let mediaType: MediaType
    
    private let localContext: NSManagedObjectContext
    @State private var state: LoadingState = .loading
    
    init(tmdbID: Int, mediaType: MediaType) {
        localContext = PersistenceController.createDisposableViewContext()
        self.tmdbID = tmdbID
        self.mediaType = mediaType
    }
    
    var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .navigationTitle(Strings.Generic.navBarLoadingTitle)
                .navigationBarTitleDisplayMode(.inline)
                .task(priority: .userInitiated) {
                    // Load the media
                    do {
                        let media = try await TMDBAPI.shared.media(
                            for: tmdbID,
                            type: mediaType,
                            context: localContext
                        )
                        await MainActor.run {
                            // Update the relevant information
                            // No need to load the thumbnail, since it will be loaded by the AsyncImage in LookupTitleView
                            self.state = .loaded(media)
                        }
                    } catch {
                        Logger.api.error("Error loading media for lookup: \(error, privacy: .public)")
                        // Just change the state. Error will be displayed automatically
                        await MainActor.run {
                            self.state = .error(error)
                        }
                    }
                }
        case .loaded(let media):
            DetailView()
                .environmentObject(media)
        case .error(let error):
            VStack {
                Text(Strings.Lookup.errorLoadingMedia(error.localizedDescription))
                Button(Strings.Generic.retryLoading) {
                    self.state = .loading
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    struct DetailView: View {
        @EnvironmentObject private var mediaObject: Media
        
        var body: some View {
            NavigationStack {
                List {
                    LookupTitleView(media: mediaObject)
                    BasicInfo()
                    if !mediaObject.watchProviders.isEmpty {
                        WatchProvidersInfo()
                    }
                    ExtendedInfo()
                }
                .listStyle(.grouped)
                .navigationTitle(mediaObject.title)
                .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(mediaObject)
        }
    }
}

struct MediaLookupDetail_Previews: PreviewProvider {
    static var previews: some View {
        MediaLookupDetail(tmdbID: 603, mediaType: .movie)
    }
}
