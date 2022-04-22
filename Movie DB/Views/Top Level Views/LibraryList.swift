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
    @ObservedObject private var library = MediaLibrary.shared
    
    private let sortingOrder: SortingOrder
    private let sortingDirection: SortingDirection
    
    private let fetchRequest: FetchRequest<Media>
    
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? self.managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    private var filteredMedia: FetchedResults<Media> {
        return fetchRequest.wrappedValue
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
            predicates.append(NSPredicate(format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
                                          "title", searchText,
                                          "originalTitle", searchText))
        }
        if true { // TODO: Only if filter is active (currently no on/off switch available to toggle that)
            predicates.append(filterSetting.predicate())
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        var sortDescriptors = [NSSortDescriptor]()
        switch sortingOrder {
        case .name:
            // Name sort descriptor gets appended at the end
            break
        case .created:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Media.creationDate,
                                                    ascending: sortingDirection == .ascending))
        case .releaseDate:
            sortDescriptors.append(NSSortDescriptor(key: "releaseDateOrFirstAired",
                                                    ascending: sortingDirection == .ascending))
        case .rating:
            sortDescriptors.append(NSSortDescriptor(key: "personalRating", ascending: sortingDirection == .ascending))
        }
        // Append the name sort descriptor as a second alternative
        sortDescriptors.append(NSSortDescriptor(keyPath: \Media.title, ascending: sortingDirection == .ascending))
        
        self.fetchRequest = FetchRequest(
            entity: Media.entity(),
            sortDescriptors: sortDescriptors,
            predicate: compoundPredicate,
            animation: nil
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
                }
                .onDelete { indexSet in
                    for offset in indexSet {
                        let media = self.filteredMedia[offset]
                        self.managedObjectContext.delete(media)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    var footerText: Text {
        guard !filteredMedia.isEmpty else {
            return Text("")
        }
        let objCount = filteredMedia.count
        let formatString = NSLocalizedString("%lld objects",
                                             tableName: "Plurals",
                                             comment: "Number of media objects in the footer")
        var footerString = String.localizedStringWithFormat(formatString, objCount)
        if objCount == self.totalMediaItems {
            footerString += NSLocalizedString(" total")
        }
        return Text(footerString)
    }
}
