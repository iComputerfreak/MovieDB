//
//  DynamicMediaListConfigurationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
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
            Form {
                // MARK: List Details
                // This binding uses the global list property defined in DynamicMediaListView, not the parameter
                // given into the closure
                MediaListEditingSection(
                    name: $list.name,
                    iconName: $list.iconName,
                    iconColor: Binding($list.iconColor, defaultValue: .label),
                    iconMode: $list.iconRenderingMode
                )
                // MARK: Filter Details
                FilterUserDataSection()
                FilterInformationSection()
                    .environmentObject(list.filterSetting!)
                FilterShowSpecificSection()
            }
            .environmentObject(list.filterSetting!)
            .navigationTitle(list.name)
            .toolbar {
                Button(Strings.Generic.dismissViewDone) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    DynamicMediaListConfigurationView(list: DynamicMediaList(context: PersistenceController.previewContext))
}
