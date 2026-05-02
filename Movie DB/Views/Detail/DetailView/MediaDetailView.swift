// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import Flow
import SwiftUI

@available(iOS 26.0, *)
struct MediaDetailView: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    // Whether the user is in edit mode right now (editing the user data)
    // !!!: We cannot use @Environment's \.editMode here since that is meant for list editing (delete, move)
    // !!!: and therefore would disable all NavigationLinks
    @State private var isEditing = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var backgroundColor: Color {
        switch colorScheme {
        case .dark: return .black
        case .light: return .white
        @unknown default: return .white
        }
    }

    var body: some View {
        if mediaObject.isFault {
            ScreenUnavailableView(
                title: Strings.Detail.navBarErrorTitle,
                systemImage: "exclamationmark.triangle",
                description: Strings.Detail.errorLoadingText
            )
                .navigationTitle(Strings.Detail.navBarErrorTitle)
        } else {
            detailView
                .toolbarTitleDisplayMode(.inline)
                // For some reason, iOS decides to use the image for the edge effect, which does not look right, so we disable it for now.
                .scrollEdgeEffectHidden(for: .top)
                // We show the title manually already
                .navigationTitle("")
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
                                AddToFavoritesButton {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .toggleFavorite))
                                }
                                AddToWatchlistButton {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .toggleWatchlist))
                                }
                                AddEnvironmentMediaToListMenu(onCompletion: {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .addToList))
                                })
                            }
                            Section {
                                ReloadMediaButton {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .reload))
                                }
                                ShareMediaButton {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .share))
                                    AnalyticsService.shared.track(.mediaShared(shareTargetType: .systemShareSheet))
                                }
                                DeleteMediaButton(onAction: {
                                    AnalyticsService.shared.track(.detailMenuActionUsed(action: .delete))
                                }, onDelete: {
                                    // Dismiss after deleting
                                    dismiss()
                                })
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

    @ViewBuilder
    private var detailView: some View {
        ParallaxHeaderContentView {
            LoadableImageView(source: .image(mediaObject.thumbnail), contentMode: .fit, alignment: .top)
        } header: {
            MediaTitleView()
        } content: {
            VStack(alignment: .leading) {
                UserDataSection()
                    .environment(\.isEditing, isEditing)
                    .frame(maxWidth: .infinity, alignment: .leading)

                BasicInfoSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                WatchProvidersSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                TrailersSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                ExtendedInfoSection()
                    .frame(maxWidth: .infinity, alignment: .leading)

                MetadataInfoSection()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
        }
    }
}

@available(iOS 26.0, *)
#Preview("Movie") {
    NavigationStack {
        MediaDetailView()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

@available(iOS 26.0, *)
#Preview("Show") {
    NavigationStack {
        MediaDetailView()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}

@available(iOS 26.0, *)
#Preview("No image") {
    NavigationStack {
        MediaDetailView()
            .environmentObject(PlaceholderData.preview.staticMinimalMovie as Media)
            .previewEnvironment()
    }
}
