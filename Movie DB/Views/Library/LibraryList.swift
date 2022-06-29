//
//  LibraryList.swift
//  Movie DB
//
//  Created by Jonas Frey on 11.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI

struct LibraryList: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest var filteredMedia: FetchedResults<Media>
    
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    // swiftlint:disable:next type_contents_order
    init(
        searchText: String,
        filterSetting: FilterSetting,
        sortingOrder: SortingOrder,
        sortingDirection: SortingDirection
    ) {
        var predicates: [NSPredicate] = []
        if !searchText.isEmpty {
            predicates.append(NSPredicate(
                format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
                "title",
                searchText,
                "originalTitle",
                searchText
            ))
        }
        if true { // TODO: Only if filter is active (currently no on/off switch available to toggle that)
            predicates.append(filterSetting.buildPredicate())
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        var sortDescriptors = [NSSortDescriptor]()
        switch sortingOrder {
        case .name:
            // Name sort descriptor gets appended at the end as a tie breaker
            break
        case .created:
            sortDescriptors.append(NSSortDescriptor(
                keyPath: \Media.creationDate,
                ascending: sortingDirection == .ascending
            ))
        case .releaseDate:
            sortDescriptors.append(NSSortDescriptor(
                key: "releaseDateOrFirstAired",
                ascending: sortingDirection == .ascending
            ))
        case .rating:
            sortDescriptors.append(NSSortDescriptor(
                key: "personalRating",
                ascending: sortingDirection == .ascending
            ))
        }
        // Append the name sort descriptor as a second alternative
        sortDescriptors.append(NSSortDescriptor(keyPath: \Media.title, ascending: sortingDirection == .ascending))
        
        _filteredMedia = FetchRequest<Media>(
            entity: Media.entity(),
            sortDescriptors: sortDescriptors,
            predicate: compoundPredicate,
            animation: .default
        )
    }
    
    var body: some View {
        List {
            Section(footer: footerText) {
                ForEach(filteredMedia) { mediaObject in
                    LibraryRow()
                        .environmentObject(mediaObject)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(Strings.Library.swipeActionDelete, role: .destructive) {
                                print("Deleting \(mediaObject.title)")
                                // Thumbnail on will be deleted automatically by Media::prepareForDeletion()
                                self.managedObjectContext.delete(mediaObject)
                            }
                            Button(Strings.Library.swipeActionReload) {
                                Task(priority: .userInitiated) {
                                    do {
                                        try await TMDBAPI.shared.updateMedia(mediaObject, context: managedObjectContext)
                                    } catch {
                                        print("Error updating \(mediaObject.title): \(error)")
                                        AlertHandler.showSimpleAlert(
                                            title: Strings.Library.Alert.updateErrorTitle,
                                            message: Strings.Library.Alert.updateErrorMessage(
                                                mediaObject.title,
                                                error.localizedDescription
                                            )
                                        )
                                    }
                                }
                            }
                            .tint(.blue)
                            #if DEBUG
                                Button {
                                    mediaObject.thumbnail = nil
                                } label: {
                                    Text(verbatim: "Debug")
                                }
                            #endif
                        }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            // If the library was just reset, we need to refresh the view
            if JFConfig.shared.libraryWasReset {
                print("Library was reset. Refreshing...")
                // TODO: self.fetchRequest.update() somehow
//                self._filteredMedia.update()
                JFConfig.shared.libraryWasReset = false
            }
        }
    }
    
    var footerText: Text {
        guard !filteredMedia.isEmpty else {
            return Text("")
        }
        let objCount = filteredMedia.count
        
        // Showing all media
        if objCount == totalMediaItems {
            return Text(Strings.Library.footerTotal(objCount))
        } else {
            // Only showing a subset of the total medias
            return Text(Strings.Library.footer(objCount))
        }
    }
}

struct LibraryList_Previews: PreviewProvider {
    static var previews: some View {
        LibraryList(searchText: "", filterSetting: .init(), sortingOrder: .created, sortingDirection: .ascending)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
