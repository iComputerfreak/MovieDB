// Copyright © 2025 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct WatchProvidersPicker: View {
    @FetchRequest(
        entity: WatchProvider.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchProvider.priority, ascending: true)],
        predicate: NSPredicate(format: "type != %@", WatchProvider.ProviderType.buy.rawValue)
    )
    var watchProviders: FetchedResults<WatchProvider>

    private var selectedProviderCount: Int {
        watchProviders.count { !$0.isHidden }
    }

    private func trackSelectionChange() {
        AnalyticsService.shared.track(
            .settingChanged(
                settingKey: .watchProviders,
                newValue: .integer(selectedProviderCount)
            )
        )
    }

    var body: some View {
        List {
            Section {
                Button(Strings.Generic.selectAll) {
                    for provider in watchProviders {
                        provider.isHidden = false
                    }
                    trackSelectionChange()
                }
                Button(Strings.Generic.selectNone) {
                    for provider in watchProviders {
                        provider.isHidden = true
                    }
                    trackSelectionChange()
                }
            }
            ForEach(watchProviders, id: \.id) { provider in
                WatchProviderPickerRow(provider: provider, onChange: trackSelectionChange)
            }
        }
        .navigationTitle(Strings.Settings.watchProviderSettingsLabel)
    }
}

struct WatchProviderPickerRow: View {
    @ObservedObject var provider: WatchProvider
    let onChange: () -> Void

    var body: some View {
        Button {
            provider.isHidden.toggle()
            onChange()
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .opacity(provider.isHidden ? 0 : 1)
                LegacyProviderView(provider: provider, iconSize: 24, showTypeLabel: false)
                Text(provider.name)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    WatchProvidersPicker()
}
