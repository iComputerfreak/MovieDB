//
//  UserListRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserListRow: View {
    @Environment(\.editMode) private var editMode
    let list: DynamicMediaList
    @State private var editingViewActive = false
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $editingViewActive) {
                UserListEditingView(list: list)
            } label: {
                EmptyView()
            }
            .hidden()
            
            NavigationLink {
                FilteredMediaList(list: list)
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

struct UserListRow_Previews: PreviewProvider {
    static let previewList: DynamicMediaList = {
        let list = DynamicMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        UserListRow(list: Self.previewList)
    }
}
