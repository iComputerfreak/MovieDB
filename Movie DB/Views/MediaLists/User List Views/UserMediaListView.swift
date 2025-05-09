//
//  UserMediaListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFUtils
import SwiftUI

extension Binding {
    init(_ base: Binding<Value?>, defaultValue: Value) {
        self.init {
            base.wrappedValue ?? defaultValue
        } set: { newValue in
            base.wrappedValue = newValue
        }
    }
}

/// Represents a media list that the user can add individual media objects to
struct UserMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var list: UserMediaList
    @Binding var selectedMediaObjects: Set<Media>
    @State private var isShowingConfiguration = false
    
    var iconColor: Binding<UIColor>? {
        Binding($list.iconColor)
    }
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMediaObjects: $selectedMediaObjects) { media in
            LibraryRow(subtitleContent: list.subtitleContent)
                .swipeActions {
                    Button(Strings.Lists.removeMediaLabel) {
                        list.medias.remove(media)
                        PersistenceController.saveContext()
                    }
                }
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            UserMediaListConfigurationView(list: list)
        }
    }
}

#Preview {
    let previewList: UserMediaList = {
        let list = UserMediaList(context: PersistenceController.xcodePreviewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    return NavigationStack {
        UserMediaListView(list: previewList, selectedMediaObjects: .constant([]))
    }
}
