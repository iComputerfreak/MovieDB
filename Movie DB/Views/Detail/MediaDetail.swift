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
                WatchProvidersInfo()
                TrailersView()
                ExtendedInfo()
                MetadataInfo()
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mediaObject.title)
            .task(priority: .userInitiated) {
                // If there is no thumbnail, try to download it again
                // If a media object really has no thumbnail (e.g., link broken), this may be a bit too much...
                if mediaObject.thumbnail == nil {
                    mediaObject.loadThumbnail()
                }
            }
            .navigationDestination(for: TagListView.NavigationDestination.self) { _ in
                TagListView.EditView(tags: $mediaObject.tags)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    CustomEditButton(isEditing: $isEditing)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            AddToFavoritesButton()
                            AddToWatchlistButton()
                            AddEnvironmentMediaToListMenu()
                        }
                        Section {
                            ReloadMediaButton()
                            ShareMediaButton()
                            DeleteMediaButton {
                                // Dismiss after deleting
                                dismiss()
                            }
                        }
                    } label: {
                        MediaMenuLabel()
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

#Preview("Movie") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
