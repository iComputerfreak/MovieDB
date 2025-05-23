//
//  UserMediaListConfigurationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.01.24.
//  Copyright © 2024 Jonas Frey. All rights reserved.
//

import OSLog
import SwiftUI

struct UserMediaListConfigurationView: View {
    @ObservedObject var list: UserMediaList
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    init(list: UserMediaList) {
        self.list = list
    }
    
    var body: some View {
        NavigationStack {
            // MARK: List Details
            ListIconConfigurator(
                name: $list.name,
                iconName: $list.iconName,
                iconColor: $list.iconColor,
                iconMode: $list.iconRenderingMode
            ) {
                SubtitleContentPicker(subtitleContent: $list.subtitleContent, showsUseDefaultOption: true)
            }
            .navigationTitle(list.name)
            .toolbar {
                DismissButton()
            }
        }
    }
}

#Preview {
    UserMediaListConfigurationView(list: UserMediaList(context: PersistenceController.xcodePreviewContext))
}
