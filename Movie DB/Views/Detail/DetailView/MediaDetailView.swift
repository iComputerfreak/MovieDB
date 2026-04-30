// Copyright © 2025 Jonas Frey. All rights reserved.

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

    let imageHeight: CGFloat = 450

    var body: some View {
        if mediaObject.isFault {
            Text(Strings.Detail.errorLoadingText)
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
        ParallaxHeaderContentView(imageHeight: imageHeight) {
            titleImage
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

    @ViewBuilder
    private var titleImage: some View {
        if let image = mediaObject.thumbnail {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight, alignment: .top)
                .ignoresSafeArea(edges: .top)
        } else {
            Color.gray
        }
    }
}

#Preview("Movie") {
    if #available(iOS 26.0, *) {
        NavigationStack {
            MediaDetailView()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
                .previewEnvironment()
        }
    } else {
        Text(verbatim: "This view is only supported on iOS 26 and newer.")
    }
}

#Preview("Show") {
    if #available(iOS 26.0, *) {
        NavigationStack {
            MediaDetailView()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
                .previewEnvironment()
        }
    } else {
        Text(verbatim: "This view is only supported on iOS 26 and newer.")
    }
}
