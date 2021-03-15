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
    
    // TODO: Give filterSettings in init and apply to fetch request
    init(searchText: String) {
        var predicates: [NSPredicate] = []
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)", "title", searchText, "originalTitle", searchText))
        }
        if true { // Filter is active
            // TODO: Rewrite FilterSettings to create a predicate
            // TODO: Apply filter predicate
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // TODO: Change if there is another option
        let sortDescriptors = [NSSortDescriptor(keyPath: \Media.title, ascending: true)]
        
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
                    LibraryRow()
                        .environmentObject(mediaObject)
                }
                .onDelete { indexSet in
                    for offset in indexSet {
                        let media = self.filteredMedia[offset]
                        self.managedObjectContext.delete(media)
                    }
                    PersistenceController.saveContext()
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    var footerText: some View {
        guard filteredMedia.count > 0 else {
            return Text("")
        }
        let objCount = filteredMedia.count
        return Text("\(objCount) object\(objCount == 1 ? "" : "s")\(objCount == self.totalMediaItems ? " total" : "")")
    }
    
}
