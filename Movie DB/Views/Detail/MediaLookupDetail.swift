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
    let tmdbID: Int
    let mediaType: MediaType
    
    private let localContext: NSManagedObjectContext
    @StateObject private var mediaObject: Media
    @State private var finishedLoading = false
    
    init(tmdbID: Int, mediaType: MediaType) {
        localContext = PersistenceController.createDisposableViewContext()
        self.tmdbID = tmdbID
        self.mediaType = mediaType
        
        let media: Media
        switch mediaType {
        case .movie:
            media = Movie(context: localContext)
            media.type = .movie
        case .show:
            media = Show(context: localContext)
            media.type = .show
        }
        _mediaObject = StateObject(wrappedValue: media)
    }
    
    var body: some View {
        if finishedLoading, !mediaObject.isFault {
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
            .environmentObject(mediaObject)
        } else {
            ProgressView()
                .navigationTitle(Strings.Generic.navBarLoadingTitle)
                .navigationBarTitleDisplayMode(.inline)
                .task(priority: .userInitiated) {
                    // Load the media
                    do {
                        let tmdbData = try await TMDBAPI.shared.tmdbData(
                            for: tmdbID,
                            type: mediaType,
                            context: localContext
                        )
                        await MainActor.run {
                            // Update the relevant information
                            self.mediaObject.update(tmdbData: tmdbData)
                            // No need to load the thumbnail, since it will be loaded by the AsyncImage in LookupTitleView
                            self.finishedLoading = true
                        }
                    } catch {
                        Logger.api.error("Error loading media for lookup: \(error, privacy: .public)")
                        AlertHandler.showError(
                            title: Strings.Lookup.Alert.errorLoadingTitle,
                            error: error
                        )
                    }
                }
        }
    }
}

struct MediaLookupDetail_Previews: PreviewProvider {
    static var previews: some View {
        MediaLookupDetail(tmdbID: 603, mediaType: .movie)
    }
}
