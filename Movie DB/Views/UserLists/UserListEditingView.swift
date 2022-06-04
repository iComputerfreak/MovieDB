//
//  UserListEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserListEditingView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var list: MediaList
    
    var body: some View {
        Form {
            Section("List Information") {
                HStack {
                    Text("Name:")
                    TextField("Name", text: $list.name)
                }
                NavigationLink {
                    SFSymbolPicker(symbol: $list.iconName)
                } label: {
                    HStack {
                        Text("Icon")
                        Spacer()
                        Image(systemName: list.iconName)
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
            Section("Filter Settings") {
                // TODO: Store filter setting on list
                FilterUserDataSection(filterSetting: .constant(FilterSetting()))
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserListEditingView_Previews: PreviewProvider {
    static let previewList: MediaList = {
        let list = MediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        NavigationView {
            UserListEditingView(list: Self.previewList)
        }
    }
}
