//
//  DynamicMediaListView.swift
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
    @Binding var selectedMediaObjects: Set<Media>
    @State private var isShowingConfiguration = false
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMediaObjects: $selectedMediaObjects) { media in
            LibraryRow(subtitleContent: list.subtitleContent)
                .mediaSwipeActions()
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            DynamicMediaListConfigurationView(list: list)
        }
    }
}

#Preview {
    let previewList: DynamicMediaList = {
        PersistenceController.xcodePreviewContext.reset()
        let list = DynamicMediaList(context: PersistenceController.xcodePreviewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        list.sortingOrder = .name
        list.sortingDirection = .ascending
        return list
    }()
    
    return NavigationStack {
        DynamicMediaListView(list: previewList, selectedMediaObjects: .constant([]))
            .previewEnvironment()
    }
}
