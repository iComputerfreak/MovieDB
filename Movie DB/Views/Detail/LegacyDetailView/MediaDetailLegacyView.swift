// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

@available(*, deprecated, renamed: "MediaDetail", message: "Use the iOS 26+ variant with a fallback.")
struct MediaDetailLegacyView: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.dismiss) private var dismiss

    // Whether the user is in edit mode right now (editing the user data)
    // !!!: We cannot use @Environment's \.editMode here since that is meant for list editing (delete, move)
    // !!!: and therefore would disable all NavigationLinks
    @State private var isEditing = false

    var body: some View {
        if mediaObject.isFault {
            Text(Strings.Detail.errorLoadingText)
                .navigationTitle(Strings.Detail.navBarErrorTitle)
        } else {
            List {
                LegacyTitleView(media: mediaObject)

                LegacyUserData()
                    .environment(\.isEditing, isEditing)

                LegacyBasicInfo()

                if !mediaObject.watchProviders.isEmpty {
                    LegacyWatchProvidersInfo()
                }

                LegacyTrailersView()
                LegacyExtendedInfo()
                LegacyMetadataInfo()
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mediaObject.title)
            .task(priority: .userInitiated) {
                // If there is no thumbnail, try to download it again
                // If a media object really has no thumbnail (e.g., link broken), this may be a bit too much...
                if mediaObject.thumbnail == nil {
                    mediaObject.loadImages()
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
        MediaDetailLegacyView()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaDetailLegacyView()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
