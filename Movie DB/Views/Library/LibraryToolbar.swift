//
//  LibraryToolbar.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import JFUtils
import OSLog
import SwiftUI

struct LibraryToolbar: ToolbarContent {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext

    // TODO: Use @EnvironmentObject
    @Binding var config: LibraryViewModel
    var editMode: Binding<EditMode>?
    @Binding var selectedMediaObjects: Set<Media>
    @State private var isShowingDeleteAlert: Bool = false
    
    let filterImageReset = "line.horizontal.3.decrease.circle"
    let filterImageSet = "line.horizontal.3.decrease.circle.fill"
    
    var filterImageName: String {
        filterSetting.isReset ? filterImageReset : filterImageSet
    }
    
    private var isEditing: Bool { editMode?.wrappedValue.isEditing ?? false }
    
    private var areAllFavorite: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.allSatisfy(\.isFavorite)
    }
    
    private var areAllOnWatchlist: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.allSatisfy(\.isOnWatchlist)
    }
    
    private var areAllSelected: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.count == MediaLibrary.shared.mediaCount()
    }
    
    var body: some ToolbarContent {
        moreMenu
        multiSelectDoneButton
        addMediaButton
    }
    
    @ToolbarContentBuilder
    private var moreMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button {
                    withAnimation {
                        editMode?.wrappedValue = isEditing ? .inactive : .active
                    }
                } label: {
                    Label(
                        isEditing ? Strings.Generic.editButtonLabelDone : Strings.Library.menuSelectLabel,
                        systemImage: "checkmark.circle"
                    )
                }
                if isEditing {
                    Section {
                        multiSelectActions
                    }
                }
                Section {
                    Button {
                        config.activeSheet = .filter
                    } label: {
                        Label(
                            Strings.Library.menuButtonFilter,
                            systemImage: filterImageName
                        )
                    }
                }
                // MARK: Sorting Options
                SortingMenuSection(sortingOrder: $config.sortingOrder, sortingDirection: $config.sortingDirection)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var multiSelectDoneButton: some ToolbarContent {
        if isEditing {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        editMode?.wrappedValue = .inactive
                    }
                } label: {
                    Text(Strings.Generic.editButtonLabelDone)
                        .bold()
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var addMediaButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                config.activeSheet = .addMedia
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("add-media")
        }
    }
}

// MARK: - Multi-Selection Actions
private extension LibraryToolbar {
    @ViewBuilder
    var multiSelectActions: some View {
        selectAllButton
        Group {
            AddMultipleToListMenu(mediaObjects: selectedMediaObjects) {
                editMode?.wrappedValue = .inactive
            }
            addToWatchlistButton
            addToFavoritesButton
            reloadButton
            deleteButton
            // TODO: Multi-select for lists details (remove)
        }
        .disabled(selectedMediaObjects.isEmpty)
    }
    
    var selectAllButton: some View {
        Button {
            do {
                if areAllSelected {
                    selectedMediaObjects = []
                } else {
                    selectedMediaObjects = Set(try managedObjectContext.fetch(Media.fetchRequest()))
                }
            } catch {
                Logger.coreData.error("Failed to fetch all media objects: \(error)")
            }
        } label: {
            if areAllSelected {
                Text(Strings.Library.multiDeselectAll)
            } else {
                Text(Strings.Library.multiSelectAll)
            }
        }
    }
    
    var addToWatchlistButton: some View {
        Button {
            let isOnWatchlist = !areAllOnWatchlist
            for media in selectedMediaObjects {
                media.isOnWatchlist = isOnWatchlist
            }
            editMode?.wrappedValue = .inactive
        } label: {
            if areAllOnWatchlist {
                Label(Strings.Detail.menuButtonRemoveFromWatchlist, systemImage: "bookmark.slash.fill")
            } else {
                Label(Strings.Detail.menuButtonAddToWatchlist, systemImage: "bookmark.fill")
            }
        }
    }
    
    var addToFavoritesButton: some View {
        Button {
            // If there is at least one media which is not favorited yet, favorite all medias
            let isFavorite = !areAllFavorite
            for media in selectedMediaObjects {
                media.isFavorite = isFavorite
            }
            editMode?.wrappedValue = .inactive
        } label: {
            // Favorite is the default action if the favorite statuses are mixed
            if areAllFavorite {
                Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
            } else {
                Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
            }
        }
    }
    
    var reloadButton: some View {
        Button {
            Task {
                for media in selectedMediaObjects {
                    do {
                        try await TMDBAPI.shared.updateMedia(media, context: managedObjectContext)
                    } catch {
                        Logger.api.error("Failed to update media object: \(error)")
                    }
                }
                await MainActor.run {
                    editMode?.wrappedValue = .inactive
                }
            }
        } label: {
            Label(Strings.Library.mediaActionReload, systemImage: "arrow.clockwise")
        }
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            isShowingDeleteAlert = true
            AlertHandler.showDeleteAlert(
                message: Strings.Library.multiDeleteAlertMessage(count: selectedMediaObjects.count)
            ) {
                withAnimation {
                    for media in selectedMediaObjects {
                        managedObjectContext.delete(media)
                    }
                }
                editMode?.wrappedValue = .inactive
            }
        } label: {
            Label(Strings.Generic.alertDeleteButtonTitle, systemImage: "trash")
        }
    }
}
