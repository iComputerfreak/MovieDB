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
    
    private var fetchRequest: FetchRequest<Media>
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? self.managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    init(searchText: String, filterSetting: FilterSetting) {
        var predicates: [NSPredicate] = []
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)", "title", searchText, "originalTitle", searchText))
        }
        if true { // TODO: Filter is active
            predicates.append(filterSetting.predicate())
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // TODO: Change if there is another option
        let sortDescriptors = [NSSortDescriptor(keyPath: \Media.creationDate, ascending: false)]
        
        self.fetchRequest = FetchRequest(
            entity: Media.entity(),
            // TODO: Replace with actual sort order
            sortDescriptors: sortDescriptors,
            predicate: compoundPredicate,
            animation: nil
        )
    }
    
    private var filteredMedia: FetchedResults<Media> {
        return fetchRequest.wrappedValue
    }
    
    var body: some View {
        List {
            Section(footer: footerText) {
                ForEach(filteredMedia) { mediaObject in
                    // Workaround so that the list items don't stay selected after going back from the detail
                    // FUTURE: Remove
                    ZStack {
                        Button("", action: {})
                        LibraryRow()
                            .environmentObject(mediaObject)
                    }
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
        guard filteredMedia.count > 0 else {
            return Text("")
        }
        let objCount = filteredMedia.count
        let formatString = NSLocalizedString("%lld objects", tableName: "Plurals", comment: "Number of media objects in the footer")
        var footerString = String.localizedStringWithFormat(formatString, objCount)
        if objCount == self.totalMediaItems {
            footerString += NSLocalizedString(" total", comment: "")
        }
        return Text(footerString)
    }
    
}
