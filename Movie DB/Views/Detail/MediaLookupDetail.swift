//
//  MediaLookupDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct MediaLookupDetail: View {
    let tmdbID: Int
    let mediaType: MediaType
    
    private let localContext: NSManagedObjectContext
    @StateObject private var mediaObject: Media
    @State private var finishedLoading = false
    
    // swiftlint:disable:next type_contents_order
    init(tmdbID: Int, mediaType: MediaType) {
        self.localContext = PersistenceController.createDisposableContext()
        self.tmdbID = tmdbID
        self.mediaType = mediaType
        
        let media: Media
        switch mediaType {
        case .movie:
            media = Movie(context: localContext)
        case .show:
            media = Show(context: localContext)
        }
        self._mediaObject = StateObject(wrappedValue: media)
    }
    
    var body: some View {
        if finishedLoading && !mediaObject.isFault {
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
                .navigationTitle(String(
                    localized: "generic.navBar.loadingTitle",
                    comment: "The navigation bar title for a view that is still loading"
                ))
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
                        print(error)
                        AlertHandler.showError(
                            title: String(
                                localized: "lookup.alert.errorLoading.title",
                                comment: "Title of an alert informing the user about an error while loading the media"
                            ),
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
