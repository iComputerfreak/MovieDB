//
//  FilterShowTypePicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterShowTypePicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    var body: some View {
        FilterMultiPicker(
            selection: $filterSetting.showTypes,
            label: { Text($0.rawValue) },
            values: ShowType.allCases.sorted(on: \.rawValue, by: <),
            title: Text(Strings.Library.Filter.showTypeLabel)
        )
    }
}

#Preview {
    FilterShowTypePicker()
        .previewEnvironment()
}
