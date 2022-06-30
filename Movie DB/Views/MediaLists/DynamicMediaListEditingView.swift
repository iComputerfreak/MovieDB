//
//  UserListEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DynamicMediaListEditingView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var list: DynamicMediaList
    
    var body: some View {
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
    }
}

struct DynamicMediaListEditingView_Previews: PreviewProvider {
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
        NavigationView {
            DynamicMediaListEditingView(list: Self.previewList)
                .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
