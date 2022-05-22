//
//  LibraryList.swift
//  Movie DB
//
//  Created by Jonas Frey on 11.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

struct LibraryList: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    private let sortingOrder: SortingOrder
    private let sortingDirection: SortingDirection
    
    private let fetchRequest: FetchRequest<Media>
    
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? self.managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    private var filteredMedia: FetchedResults<Media> {
        fetchRequest.wrappedValue
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
            predicates.append(filterSetting.predicate())
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
        
        self.fetchRequest = FetchRequest(
            entity: Media.entity(),
            sortDescriptors: sortDescriptors,
            predicate: compoundPredicate,
            animation: .default
        )
        self.sortingOrder = sortingOrder
        self.sortingDirection = sortingDirection
    }
    
    var body: some View {
        List {
            Section(footer: footerText) {
                ForEach(filteredMedia) { mediaObject in
                    LibraryRow()
                        .environmentObject(mediaObject)
                        .fixHighlighting()
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(String(
                                localized: "library.list.swipe.delete",
                                comment: "The label for the delete swipe action in the library list"
                            ), role: .destructive) {
                                print("Deleting \(mediaObject.title)")
                                self.managedObjectContext.delete(mediaObject)
                            }
                            Button(String(
                                localized: "library.list.swipe.reload",
                                comment: "The label for the reload swipe action in the library list"
                            )) {
                                Task(priority: .userInitiated) {
                                    do {
                                    try await TMDBAPI.shared.updateMedia(mediaObject, context: managedObjectContext)
                                    } catch {
                                        print("Error updating \(mediaObject.title): \(error)")
                                        AlertHandler.showSimpleAlert(
                                            title: String(
                                                localized: "library.alert.errorUpdating.title",
                                                // swiftlint:disable:next line_length
                                                comment: "Title of an alert informing the user about an error during a media update"
                                            ),
                                            message: String(
                                                // swiftlint:disable line_length
                                                localized: "library.alert.errorUpdating.message \(mediaObject.title) \(error.localizedDescription)",
                                                comment: "The message of an alert informing the user about an error during a media update. The first argument is the title of the media object and the second argument is the error description."
                                                // swiftlint:enable line_length
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
    }
    
    var footerText: Text {
        guard !filteredMedia.isEmpty else {
            return Text("")
        }
        let objCount = filteredMedia.count
        
        // Showing all media
        if objCount == self.totalMediaItems {
            return Text(
                "library.list.footer.total \(objCount)",
                comment: "The total amount of media items in the library. Shown in the footer below the list."
            )
        // Only showing a subset of the total medias
        } else {
            return Text(
                "library.list.footer \(objCount)",
                comment: "The total amount of media items currently displayed. Shown in the footer below the list."
            )
        }
    }
}

struct LibraryList_Previews: PreviewProvider {
    static var previews: some View {
        LibraryList(searchText: "", filterSetting: .init(), sortingOrder: .created, sortingDirection: .ascending)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
