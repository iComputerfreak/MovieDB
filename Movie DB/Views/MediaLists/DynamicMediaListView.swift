//
//  UserListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DynamicMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var list: DynamicMediaList
    @Binding var selectedMedia: Media?
    
    var body: some View {
        if editMode?.wrappedValue.isEditing ?? false {
            // Editing destination
            Form {
                // MARK: List Details
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
                // MARK: Filter Details
                FilterUserDataSection(filterSetting: list.filterSetting!)
                FilterInformationSection(filterSetting: list.filterSetting!)
                FilterShowSpecificSection(filterSetting: list.filterSetting!)
            }
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            // Default destination
            FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
                LibraryRow()
                    .environmentObject(media)
            }
        }
    }
}

struct DynamicMediaListView_Previews: PreviewProvider {
    static let previewList: DynamicMediaList = {
        PersistenceController.previewContext.reset()
        let list = DynamicMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        list.sortingOrder = .name
        list.sortingDirection = .ascending
        return list
    }()
    
    static var previews: some View {
        NavigationStack {
            DynamicMediaListView(list: Self.previewList, selectedMedia: .constant(nil))
                .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
