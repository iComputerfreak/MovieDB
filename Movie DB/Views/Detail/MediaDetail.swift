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
    @State private var showingAddToSheet = false
    
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
            .sheet(isPresented: $showingAddToSheet, content: {
                SelectUserListView(mediaObject: mediaObject)
            })
            .listStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mediaObject.title)
            .task(priority: .userInitiated) {
                // If there is no thumbnail, try to download it again
                // If a media object really has no thumbnail (e.g., link broken), this may be a bit too much...
                if mediaObject.thumbnail == nil {
                    await mediaObject.loadThumbnail()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        mediaObject.isOnWatchlist.toggle()
                    } label: {
                        let imageName = mediaObject.isOnWatchlist ? "bookmark.fill" : "bookmark"
                        Image(systemName: imageName)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        EditButton()
                        Section {
                            Button {
                                mediaObject.isFavorite.toggle()
                            } label: {
                                if mediaObject.isFavorite {
                                    Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
                                } else {
                                    Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
                                }
                            }
                            // Present popup that asks to which list the media should be added
                            Button {
                                self.showingAddToSheet = true
                            } label: {
                                Label("Add to List...", systemImage: "text.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
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
