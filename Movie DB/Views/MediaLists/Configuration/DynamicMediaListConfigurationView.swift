//
//  DynamicMediaListConfigurationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import OSLog
import SwiftUI

struct DynamicMediaListConfigurationView: View {
    @ObservedObject var list: DynamicMediaList
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    init(list: DynamicMediaList) {
        self.list = list
        if list.filterSetting == nil {
            Logger.coreData.warning("Dynamic media list has no FilterSetting. Recovering by creating a new one.")
            assertionFailure("List should have a FilterSetting.")
            list.filterSetting = FilterSetting(context: managedObjectContext)
        }
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
                Section {
                    NavigationLink {
                        DynamicMediaListFilterConfigurationView(onDismiss: dismiss)
                            .environmentObject(list.filterSetting!)
                    } label: {
                        Text(
                            "lists.configuration.header.filterSettings",
                            comment: "The header for the list configuration view's filter settings."
                        )
                    }
                    SubtitleContentPicker(subtitleContent: $list.subtitleContent, showsUseDefaultOption: true)
                } header: {
                    Text(
                        "lists.configuration.header.settings",
                        comment: "The header for the list configuration view's settings section."
                    )
                }
            }
            .navigationTitle(list.name)
            .toolbar {
                DismissButton()
            }
        }
    }
}

#Preview {
    DynamicMediaListConfigurationView(list: DynamicMediaList(context: PersistenceController.xcodePreviewContext))
}
