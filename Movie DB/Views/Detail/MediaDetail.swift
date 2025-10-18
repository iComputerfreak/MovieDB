//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Flow
import SwiftUI

struct MediaDetail: View {

    var body: some View {
        if #available(iOS 26.0, *) {
            MediaDetailView()
        } else {
            MediaDetailLegacyView()
        }
    }
}

struct MediaDetailLegacyView: View {
    var body: some View {
        Text("TODO: Implement")
    }
}

#Preview("Movie") {
    if #available(iOS 26.0, *) {
        NavigationStack {
            MediaDetail()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
                .previewEnvironment()
        }
    } else {
        Text("Fallback iOS < 26.0")
    }
}

#Preview("Show") {
    if #available(iOS 26.0, *) {
        NavigationStack {
            MediaDetail()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
                .previewEnvironment()
        }
    } else {
        Text("Fallback iOS < 26.0")
    }
}


@available(iOS 26.0, *)
struct MediaDetailView: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    // Whether the user is in edit mode right now (editing the user data)
    // !!!: We cannot use @Environment's \.editMode here since that is meant for list editing (delete, move)
    // !!!: and therefore would disable all NavigationLinks
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    @State private var titleViewHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    let scrollCoordinateSpaceName: String = "scroll"

    let imageHeight: CGFloat = 400
    let backdropGradient: LinearGradient = .init(
        stops: [
            .init(color: .black, location: 0),
            //            .init(color: .black.opacity(0.8), location: 0.5),
            .init(color: .clear, location: 1),
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    var body: some View {
        if mediaObject.isFault {
            Text(Strings.Detail.errorLoadingText)
                .navigationTitle(Strings.Detail.navBarErrorTitle)
        } else {
            detailView
            //            List {
            //                TitleView(media: mediaObject)
            //                UserData()
            //                    .environment(\.isEditing, isEditing)
            //                BasicInfo()
            //                WatchProvidersInfo()
            //                TrailersView()
            //                ExtendedInfo()
            //                MetadataInfo()
            //            }
            //            .listStyle(.insetGrouped)
                .toolbarTitleDisplayMode(.inline)
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
        ZStack(alignment: .top) {
            backdropImage
                .frame(height: imageHeight)

            ScrollView {
                VStack(spacing: 0) {
                    // Leave place for the backdrop
                    Spacer()
                        .frame(maxWidth: .infinity)
                        .frame(height: imageHeight)

                        .frame(height: imageHeight)
                        .overlay(alignment: .bottom) {
                            titleInfoView
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                // Some extra top padding for the gradient to run out
                                .padding(.top, 32)
                                .frame(maxWidth: .infinity)
                                .background {
                                    backdropGradient
                                }
                                .background {
                                    backdropImage
                                        .padding(.top, -(imageHeight - titleViewHeight - scrollOffset))
                                        .blur(radius: 30)
                                        .frame(height: titleViewHeight, alignment: .top)
                                        .clipped()
                                        .mask(backdropGradient)
                                }
                                .background {
                                    // We need to somehow send the height of the title view to the blurred background image,
                                    // so it can adjust its blur to only be behind the title info view.
                                    // This is necessary, because the background image (and its blur) must stay out of the ScrollView.
                                    GeometryReader { proxy in
                                        DispatchQueue.main.async {
                                            titleViewHeight = proxy.size.height
                                        }
                                        return Color.clear
                                    }
                                }
                        }

                    Color.black
                        .frame(maxWidth: .infinity)
                        .frame(height: 1200)
                }
                .background {
                    // We need to somehow send the height of the title view to the blurred background image,
                    // so it can adjust its blur to only be behind the title info view.
                    // This is necessary, because the background image (and its blur) must stay out of the ScrollView.
                    GeometryReader { proxy in
                        DispatchQueue.main.async {
                            scrollOffset = -proxy.frame(in: .named(scrollCoordinateSpaceName)).minY
                        }
                        return Color.clear
                    }
                }
            }
            .coordinateSpace(name: scrollCoordinateSpaceName)
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var backdropImage: some View {
        let image = Group {
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

        image
    }

    private var titleInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mediaObject.title)
                .font(.title.bold())

            HStack {
                StarRatingView(rating: mediaObject.personalRating)
                if mediaObject.isOnWatchlist {
                    Image(systemName: PredicateMediaList.watchlist.iconName)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.blue)
                }
                if mediaObject.isFavorite {
                    Image(systemName: PredicateMediaList.favorites.iconName)
                        .symbolRenderingMode(.multicolor)
                }
                WatchStateLabel()
            }

            Text(mediaObject.overview ?? "")
                .lineLimit(3)
            HFlow {
                Text("2025 · 2 hr 35 min")
                if let rating = mediaObject.parentalRating {
                    ParentalRatingView(rating: rating)
                }
            }
            .foregroundStyle(.secondary)
        }
        .font(.system(size: 14))
        .foregroundStyle(.white)
    }
}
