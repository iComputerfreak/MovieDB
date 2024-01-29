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
    
    init(list: UserMediaList) {
        self.list = list
    }
    
    var body: some View {
        ListConfigurationView(list: list) { list in
            ListIconConfigurator(
                name: $list.name,
                iconName: $list.iconName,
                iconColor: $list.iconColor,
                iconMode: $list.iconRenderingMode
            ) {}
        }
    }
}

#Preview {
    UserMediaListConfigurationView(list: UserMediaList(context: PersistenceController.previewContext))
}
