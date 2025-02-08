// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct WatchProvidersPicker: View {
    @FetchRequest(
        entity: WatchProvider.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchProvider.priority, ascending: true)],
        predicate: NSPredicate(format: "type != %@", WatchProvider.ProviderType.buy.rawValue)
    )
    var watchProviders: FetchedResults<WatchProvider>

    var body: some View {
        List {
            Section {
                Button(Strings.Generic.selectAll) {
                    for provider in watchProviders {
                        provider.isHidden = false
                    }
                }
                Button(Strings.Generic.selectNone) {
                    for provider in watchProviders {
                        provider.isHidden = true
                    }
                }
            }
            ForEach(watchProviders, id: \.id) { provider in
                WatchProviderPickerRow(provider: provider)
            }
        }
        .navigationTitle(Strings.Settings.watchProviderSettingsLabel)
    }
}

struct WatchProviderPickerRow: View {
    @ObservedObject var provider: WatchProvider

    var body: some View {
        Button {
            provider.isHidden.toggle()
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .opacity(provider.isHidden ? 0 : 1)
                ProviderView(provider: provider, iconSize: 24, showTypeLabel: false)
                Text(provider.name)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    WatchProvidersPicker()
}
