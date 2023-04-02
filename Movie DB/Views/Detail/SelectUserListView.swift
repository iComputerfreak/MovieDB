//
//  SelectUserListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct SelectUserListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
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
            .navigationTitle(Strings.AddToList.title)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Strings.AddToList.toolbarButtonCancel) {
                    dismiss()
                }
            }
        }
    }
}

struct SelectUserListView_Previews: PreviewProvider {
    static var previews: some View {
        SelectUserListView(mediaObject: PlaceholderData.preview.staticMovie)
            .environment(\.managedObjectContext, PlaceholderData.preview.context)
    }
}
