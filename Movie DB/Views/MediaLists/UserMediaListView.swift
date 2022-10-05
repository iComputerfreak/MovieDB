//
//  UserMediaListEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var list: UserMediaList
    @Binding var selectedMedia: Media?
    
    var body: some View {
        if editMode?.wrappedValue.isEditing ?? false {
            // Editing view
            Form {
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
            }
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            // Default destination
            FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
                // NavigationLink to the detail
                NavigationLink(value: media) {
                    LibraryRow()
                        .environmentObject(media)
                        // Media delete
                        .swipeActions {
                            Button(Strings.Lists.deleteLabel) {
                                list.medias.remove(media)
                                PersistenceController.saveContext()
                            }
                        }
                }
            }
        }
    }
}

struct UserMediaListView_Previews: PreviewProvider {
    static let previewList: UserMediaList = {
        let list = UserMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        NavigationStack {
            UserMediaListView(list: Self.previewList, selectedMedia: .constant(nil))
        }
    }
}
