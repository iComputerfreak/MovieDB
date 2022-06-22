//
//  SelectUserListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct SelectUserListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var lists: FetchedResults<UserMediaList>
    
    @ObservedObject var mediaObject: Media
    
    var body: some View {
        NavigationStack {
            List(lists) { list in
                let isDisabled = list.medias.contains(mediaObject)
                Button {
                    mediaObject.userLists.insert(list)
                    dismiss()
                } label: {
                    Label(list.name, systemImage: list.iconName)
                        .symbolRenderingMode(isDisabled ? .monochrome : .multicolor)
                }
                .disabled(isDisabled)
                .foregroundColor(isDisabled ? .gray : .primary)
            }
            .navigationTitle("Add to...")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct SelectUserListView_Previews: PreviewProvider {
    static let context: NSManagedObjectContext = {
        let context = PersistenceController.previewContext
        context.reset()
        let m = PlaceholderData.createMovie()
        let l1 = UserMediaList(context: context)
        l1.iconName = "trash"
        l1.name = "Trash List"
        l1.medias.insert(m)
        let l2 = UserMediaList(context: context)
        l2.iconName = "star.fill"
        l2.name = "Star List"
        return context
    }()
    
    static var previews: some View {
        // swiftlint:disable:next force_try
        SelectUserListView(mediaObject: try! context.fetch(Media.fetchRequest()).first!)
        .environment(\.managedObjectContext, context)
    }
}
