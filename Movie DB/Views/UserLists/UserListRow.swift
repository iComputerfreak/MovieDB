//
//  UserListRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserListRow: View {
    let list: MediaList
    
    var body: some View {
        NavigationLink {
            UserListEditingView(list: list)
        } label: {
            Label(list.name, systemImage: list.iconName)
                .symbolRenderingMode(.multicolor)
        }
    }
}

struct UserListRow_Previews: PreviewProvider {
    static let previewList: MediaList = {
        let list = MediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        UserListRow(list: Self.previewList)
    }
}
