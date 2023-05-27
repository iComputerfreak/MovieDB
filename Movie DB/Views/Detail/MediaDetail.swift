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
    @Environment(\.managedObjectContext) private var managedObjectContext
    // Whether the user is in edit mode right now (editing the user data)
    // !!!: We cannot use @Environment's \.editMode here since that is meant for list editing (delete, move)
    // !!!: and therefore would disable all NavigationLinks
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if mediaObject.isFault {
            Text(Strings.Detail.errorLoadingText)
                .navigationTitle(Strings.Detail.navBarErrorTitle)
        } else {
            List {
                TitleView(media: mediaObject)
                UserData()
                    .environment(\.isEditing, isEditing)
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
            .task(priority: .userInitiated) {
                // If there is no thumbnail, try to download it again
                // If a media object really has no thumbnail (e.g., link broken), this may be a bit too much...
                if mediaObject.thumbnail == nil {
                    mediaObject.loadThumbnail()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? Strings.Generic.editButtonLabelDone : Strings.Generic.editButtonLabelEdit) {
                        withAnimation(.easeInOut) {
                            isEditing.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    MediaMenu(mediaObject: mediaObject) {
                        // On delete, dismiss
                        dismiss()
                    }
                }
            }
            .onDisappear {
                if mediaObject.hasChanges {
                    PersistenceController.saveContext()
                }
            }
        }
    }
}

struct MediaDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediaDetail()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
        }
        .previewDisplayName("Movie")
        
        NavigationStack {
            MediaDetail()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
        }
        .previewDisplayName("Show")
    }
}
