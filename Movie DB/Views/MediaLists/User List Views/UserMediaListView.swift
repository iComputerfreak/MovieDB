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
            NavigationLink(value: media) {
                LibraryRow()
                    .environmentObject(media)
                    // Media delete
                    .swipeActions {
                        Button(Strings.Lists.removeMediaLabel) {
                            list.medias.remove(media)
                            PersistenceController.saveContext()
                        }
                    }
            }
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            ListConfigurationView(list: list) { list in
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
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
