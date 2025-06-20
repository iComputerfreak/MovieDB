// Copyright © 2024 Jonas Frey. All rights reserved.

import OSLog
import SwiftUI

struct MultiSelectionMenu: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @Binding var selectedMediaObjects: Set<Media>
    var allMediaObjects: Set<Media>
    @State private var isShowingDeleteAlert: Bool = false
    
    private var isEditing: Bool { editMode?.wrappedValue.isEditing ?? false }
    
    private var areAllFavorite: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.allSatisfy(\.isFavorite)
    }
    
    private var areAllOnWatchlist: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.allSatisfy(\.isOnWatchlist)
    }
    
    private var areAllSelected: Bool {
        !selectedMediaObjects.isEmpty && selectedMediaObjects.count == allMediaObjects.count
    }
    
    var body: some View {
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
    }
}

// MARK: - Multi-Selection Actions
private extension MultiSelectionMenu {
    @ViewBuilder
    var multiSelectActions: some View {
        selectAllButton
        Group {
            AddMultipleToListMenu(mediaObjects: selectedMediaObjects) {
                dismissEditing()
            }
            addToWatchlistButton
            addToFavoritesButton
            markAsWatchedButton
            markAsNotWatchedButton
            reloadButton
            deleteButton
        }
        .disabled(selectedMediaObjects.isEmpty)
    }
    
    var selectAllButton: some View {
        Button {
            if areAllSelected {
                selectedMediaObjects = []
            } else {
                selectedMediaObjects = allMediaObjects
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
            dismissEditing()
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
            dismissEditing()
        } label: {
            // Favorite is the default action if the favorite statuses are mixed
            if areAllFavorite {
                Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
            } else {
                Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
            }
        }
    }

    var markAsWatchedButton: some View {
        Button {
            for media in selectedMediaObjects {
                if let movie = media as? Movie {
                    movie.watched = .watched
                } else if let show = media as? Show {
                    let maxSeason = show.latestNonEmptySeasonNumber ?? 1
                    show.watched = .season(maxSeason)
                } else {
                    Logger.library.warning(
                        "Media '\(media.title)' with type \(media.type.rawValue) is neither a Movie, nor a Show."
                    )
                }
            }
            PersistenceController.saveContext()
        } label: {
            Label(Strings.Detail.menuButtonMarkAsWatched, systemImage: "checkmark.circle.fill")
        }
    }

    var markAsNotWatchedButton: some View {
        Button {
            for media in selectedMediaObjects {
                if let movie = media as? Movie {
                    movie.watched = .notWatched
                } else if let show = media as? Show {
                    show.watched = .notWatched
                } else {
                    Logger.library.warning(
                        "Media '\(media.title)' with type \(media.type.rawValue) is neither a Movie, nor a Show."
                    )
                }
            }
            PersistenceController.saveContext()
        } label: {
            Label(Strings.Detail.menuButtonMarkAsNotWatched, systemImage: "circle")
        }
    }

    var reloadButton: some View {
        Button {
            Task {
                for media in selectedMediaObjects {
                    do {
                        try await TMDBAPI.shared.updateMedia(media, context: managedObjectContext)
                        await PersistenceController.saveContext(managedObjectContext)
                    } catch {
                        Logger.api.error("Failed to update media object: \(error)")
                    }
                }
            }
            // Dismiss immediately
            dismissEditing()
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
                dismissEditing()
            }
        } label: {
            Label(Strings.Generic.alertDeleteButtonTitle, systemImage: "trash")
        }
    }
    
    private func dismissEditing() {
        DispatchQueue.main.async {
            selectedMediaObjects = []
            withAnimation {
                editMode?.wrappedValue = .inactive
            }
        }
    }
}

#Preview {
    MultiSelectionMenu(selectedMediaObjects: .constant([]), allMediaObjects: [])
        .environment(\.editMode, .constant(.active))
        .previewEnvironment()
}
