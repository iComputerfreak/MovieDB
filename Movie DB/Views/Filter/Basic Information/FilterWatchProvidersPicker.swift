// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct FilterWatchProvidersPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext

    var watchProvidersProxy: Binding<[WatchProvider]> {
        .init {
            Array(filterSetting.watchProviders)
                .filter(where: \.type, isNotEqualTo: .buy)
                .sorted(on: \.priority, by: <)
        } set: { newValue in
            // We need to move the providers into the filterSetting context first
            filterSetting.watchProviders = Set(newValue.compactMap { provider in
                self.managedObjectContext.object(with: provider.objectID) as? WatchProvider
            })
        }
    }

    var body: some View {
        FilterMultiPicker(
            selection: watchProvidersProxy,
            label: { Text($0.name) },
            values: Utils.allNonBuyWatchProviders(context: self.managedObjectContext),
            title: Text(Strings.Library.Filter.watchProvidersLabel)
        )
    }
}

#Preview {
    FilterWatchProvidersPicker()
        .previewEnvironment()
}
