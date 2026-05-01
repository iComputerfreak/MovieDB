// Copyright © 2023 Jonas Frey. All rights reserved.

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

#Preview {
    FilterMediaStatusPicker()
        .previewEnvironment()
}
