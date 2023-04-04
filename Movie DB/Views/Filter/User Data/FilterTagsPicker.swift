//
//  FilterTagsPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterTagsPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    )
    var allTags: FetchedResults<Tag>
    
    var body: some View {
        FilterMultiPicker(
            selection: Binding(
                get: { Array(filterSetting.tags).sorted(on: \.name, by: <) },
                set: { filterSetting.tags = Set($0) }
            ),
            label: { Text($0.name) },
            values: Array(allTags),
            title: Text(Strings.Library.Filter.tagsLabel)
        )
    }
}

struct FilterTagsPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterTagsPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
