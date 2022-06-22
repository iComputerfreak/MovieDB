//
//  UserMediaListEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserMediaListEditingView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var list: UserMediaList
    
    var body: some View {
        Form {
            MediaListEditingSection(name: $list.name, iconName: $list.iconName)
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserMediaListEditingView_Previews: PreviewProvider {
    static let previewList: UserMediaList = {
        let list = UserMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        return list
    }()
    
    static var previews: some View {
        NavigationView {
            UserMediaListEditingView(list: Self.previewList)
        }
    }
}
