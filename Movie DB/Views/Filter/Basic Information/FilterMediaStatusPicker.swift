//
//  FilterMediaStatusPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterMediaStatusPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    var body: some View {
        FilterMultiPicker(
            selection: $filterSetting.statuses,
            label: { Text($0.rawValue) },
            values: MediaStatus.allCases.sorted(on: \.rawValue, by: <),
            title: Text(Strings.Library.Filter.mediaStatusLabel)
        )
    }
}

struct FilterMediaStatusPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterMediaStatusPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
