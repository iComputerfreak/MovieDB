// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
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
                    .accessibilityIdentifier("filter-settings")
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
        .onChange(of: list.name) { _, _ in
            AnalyticsService.shared.track(.listConfigurationChanged(field: .name))
        }
        .onChange(of: list.iconName) { _, _ in
            AnalyticsService.shared.track(.listConfigurationChanged(field: .iconName))
        }
        .onChange(of: list.iconColor) { _, _ in
            AnalyticsService.shared.track(.listConfigurationChanged(field: .iconColor))
        }
        .onChange(of: list.iconRenderingMode) { _, _ in
            AnalyticsService.shared.track(.listConfigurationChanged(field: .iconRenderingMode))
        }
        .onChange(of: list.subtitleContent) { _, _ in
            AnalyticsService.shared.track(.listConfigurationChanged(field: .subtitleContent))
        }
    }
}

#Preview {
    DynamicMediaListConfigurationView(list: DynamicMediaList(context: PersistenceController.xcodePreviewContext))
}
