// Copyright © 2025 Jonas Frey. All rights reserved.

import Flow
import SwiftUI

// TODO: Move out, clean up
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

    @State private var titleViewHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    let scrollCoordinateSpaceName: String = "scroll"

    private var backgroundColor: Color {
        switch colorScheme {
        case .dark: return .black
        case .light: return .white
        @unknown default: return .white
        }
    }

    // TODO: Move out
    let imageHeight: CGFloat = 450
    private var backdropGradient: LinearGradient {
        .init(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .clear, location: 1),
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

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

    @ViewBuilder
    private var detailView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Leave place for the backdrop
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: imageHeight)
                    .overlay(alignment: .bottom) {
                        MediaTitleView()
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            // Some extra top padding for the gradient to run out
                            .padding(.top, 48)
                            .frame(maxWidth: .infinity)
                            .background(backdropGradient)
                            .background {
                                titleImage
                                    .padding(.top, -(imageHeight - titleViewHeight - scrollOffset))
                                    .blur(radius: 30)
                                    .frame(height: titleViewHeight, alignment: .top)
                                    .clipped()
                                    .mask(backdropGradient)
                            }
                            .background {
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: TitleViewHeightKey.self, value: proxy.size.height)
                                }
                            }
                            .onPreferenceChange(TitleViewHeightKey.self) { titleViewHeight in
                                self.titleViewHeight = titleViewHeight
                            }
                    }

                VStack(alignment: .leading) {
                    GroupBox {
                        LegacyUserData()
                            .environment(\.isEditing, isEditing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.userDataSectionHeader,
                            systemImage: "person.fill"
                        )
                    }

                    GroupBox {
                        LegacyBasicInfo()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.basicInfoSectionHeader,
                            systemImage: "info.circle"
                        )
                    }

                    GroupBox {
                        LegacyWatchProvidersInfo()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.watchProvidersSectionHeader,
                            systemImage: "tv"
                        )
                    }

                    GroupBox {
                        LegacyTrailersView()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.trailersSectionHeader,
                            systemImage: "play.rectangle"
                        )
                    }

                    GroupBox {
                        LegacyExtendedInfo()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.extendedInfoSectionHeader,
                            systemImage: "ellipsis.circle"
                        )
                    }

                    GroupBox {
                        LegacyMetadataInfo()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label(
                            Strings.Detail.metadataSectionHeader,
                            systemImage: "paperclip"
                        )
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
            }
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -proxy.frame(in: .named(scrollCoordinateSpaceName)).minY
                        )
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset in
                self.scrollOffset = scrollOffset
            }
        }
        .background(alignment: .top) {
            titleImage
                .frame(height: imageHeight)
        }
        .coordinateSpace(name: scrollCoordinateSpaceName)
        .ignoresSafeArea(edges: .top)
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
