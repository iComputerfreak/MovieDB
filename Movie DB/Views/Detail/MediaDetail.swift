//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaDetail : View {
    
    @ObservedObject private var library = MediaLibrary.shared
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    var body: some View {
        // Group is needed so swift can infer the return type
        Group {
            List {
                TitleView(title: mediaObject.tmdbData?.title ?? "<ERROR>", year: mediaObject.year, thumbnail: mediaObject.thumbnail)
                UserData()
                BasicInfo()
                ExtendedInfo()
            }
            .listStyle(GroupedListStyle())
        }
        .navigationBarTitle(Text(mediaObject.tmdbData?.title ?? "Loading error!"), displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
        .onAppear {
            // If there is no thumbnail, try to re-download it again
            // If a media object really has no thumbnail, this may be a bit too much...
            if mediaObject.thumbnail == nil {
                mediaObject.loadThumbnail()
            }
        }
        // When the detail disappears (e.g. editing ended) we update the problems array of the library
        .onDisappear {
            self.library.updateProblems(for: mediaObject)
        }
    }
}

#if DEBUG
struct MediaDetail_Previews : PreviewProvider {
    static var previews: some View {
        MediaDetail()
            .environmentObject(PlaceholderData.movie as Media)
    }
}
#endif
