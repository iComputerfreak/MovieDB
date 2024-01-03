//
//  UserMediaListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

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
    @Binding var selectedMedia: Media?
    @State private var isShowingConfiguration = false
    
    var iconColor: Binding<UIColor>? {
        Binding($list.iconColor)
    }
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
            // NavigationLink to the detail
            NavigationLink(value: media) {
                LibraryRow()
                    .swipeActions {
                        Button(Strings.Lists.removeMediaLabel) {
                            list.medias.remove(media)
                            PersistenceController.saveContext()
                        }
                    }
                    .mediaContextMenu()
                    .environmentObject(media)
            }
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            ListConfigurationView(list: list) { list in
                MediaListEditingSection(
                    name: $list.name,
                    iconName: $list.iconName,
                    iconColor: Binding($list.iconColor, defaultValue: UIColor.darkText),
                    iconMode: $list.iconRenderingMode
                )
            }
        }
    }
}

#Preview {
    let previewList: UserMediaList = {
        let list = UserMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    return NavigationStack {
        UserMediaListView(list: previewList, selectedMedia: .constant(nil))
    }
}
