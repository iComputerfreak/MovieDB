//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaDetail: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        if mediaObject.isFault {
            Text(Strings.Detail.errorLoadingText)
            .navigationTitle(Strings.Detail.navBarErrorTitle)
        } else {
            List {
                TitleView(media: mediaObject)
                UserData()
                BasicInfo()
                if !mediaObject.watchProviders.isEmpty {
                    WatchProvidersInfo()
                }
                ExtendedInfo()
                MetadataInfo()
            }
            .listStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mediaObject.title)
            .navigationBarItems(trailing: EditButton())
            .task(priority: .userInitiated) {
                // If there is no thumbnail, try to download it again
                // If a media object really has no thumbnail (e.g., link broken), this may be a bit too much...
                if mediaObject.thumbnail == nil {
                    await mediaObject.loadThumbnail()
                }
            }
        }
    }
}

struct MediaDetail_Previews: PreviewProvider {
    static var previews: some View {
        MediaDetail()
            .environmentObject(PlaceholderData.movie as Media)
    }
}
