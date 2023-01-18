//
//  UserListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a media list that is defined by a filter and dynamically updates according to the filter
struct DynamicMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var list: DynamicMediaList
    @Binding var selectedMedia: Media?
    @State private var isShowingConfiguration = false
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
            LibraryRow()
                .environmentObject(media)
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            ListConfigurationView(list: list) { list in
                // MARK: List Details
                // This binding uses the global list property defined in DynamicMediaListView, not the parameter
                // given into the closure
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
                // MARK: Filter Details
                FilterUserDataSection(filterSetting: list.filterSetting!)
                FilterInformationSection(filterSetting: list.filterSetting!)
                FilterShowSpecificSection(filterSetting: list.filterSetting!)
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
