//
//  UserMediaListEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a media list that the user can add individual media objects to
struct UserMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var list: UserMediaList
    @Binding var selectedMedia: Media?
    @State private var isShowingConfiguration = false
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
            // NavigationLink to the detail
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
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .popover(isPresented: $isShowingConfiguration) {
            EditingView(list: list)
        }
    }
}

/// Represents the configuration view for this type of list
private struct EditingView: View {
    @ObservedObject var list: UserMediaList // TODO: Increase class level
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
            }
            .toolbar {
                // TODO: Localize
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .bold()
                }
            }
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
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
