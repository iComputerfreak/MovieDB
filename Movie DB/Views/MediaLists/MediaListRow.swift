//
//  UserListRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaListRow<RowContent: View>: View {
    @Environment(\.editMode) private var editMode
    let list: any MediaListProtocol
    @State private var editingViewActive = false
    var rowContent: (Media) -> RowContent
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $editingViewActive) {
                if let userList = list as? UserMediaList {
                    UserMediaListEditingView(list: userList)
                } else if let dynamicList = list as? DynamicMediaList {
                    DynamicMediaListEditingView(list: dynamicList)
                }
            } label: {
                EmptyView()
            }
            .hidden()
            
            NavigationLink {
                FilteredMediaList(list: list, rowContent: rowContent)
            } label: {
                Label(list.name, systemImage: list.iconName)
                    .symbolRenderingMode(.multicolor)
            }
            .gesture((editMode?.wrappedValue.isEditing ?? false) ? tapGesture : nil)
        }
    }
    
    var tapGesture: some Gesture {
        TapGesture().onEnded {
            self.editingViewActive = true
        }
    }
    
    func testasdf() {
        print("Test")
    }
}

struct MediaListRow_Previews: PreviewProvider {
    static let previewList: DynamicMediaList = {
        let list = DynamicMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        MediaListRow(list: Self.previewList) { media in
            LibraryRow()
                .environmentObject(media)
        }
    }
}