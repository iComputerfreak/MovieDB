// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Content of the iOS 26+ tab bar bottom accessory shown while a library update/reload is in
/// progress. Reads `LibraryUpdateStatus.shared` directly (the same pattern used by
/// `StoreManager.shared`), so no environment injection is required.
///
/// If multiple updates happen to be running concurrently, only the most recently started one is
/// shown, since the accessory only has room for a single row.
@available(iOS 26.0, *)
struct LibraryUpdateBottomAccessory: View {
    var status: LibraryUpdateStatus = .shared

    private var latestEntry: LibraryUpdateStatus.Entry? {
        status.entries.values.max { $0.startedAt < $1.startedAt }
    }

    var body: some View {
        if let entry = latestEntry {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(Strings.Library.UpdateStatus.title(for: entry.origin))
                    Spacer()
                    Text(Strings.Library.UpdateStatus.progress(entry.current, entry.total))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .font(.footnote)
                ProgressView(value: entry.percentage)
                    .progressViewStyle(.linear)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    let status = LibraryUpdateStatus.shared
    let id = status.begin(origin: .manualReload, total: 340)

    return TabView {
        Tab("Tab1", systemImage: "square.fill") {
            EmptyView()
        }
        Tab("Tab2", systemImage: "triangle.fill") {
            EmptyView()
        }
        Tab("Tab3", systemImage: "circle.fill") {
            EmptyView()
        }
    }
    .tabViewBottomAccessory {
        LibraryUpdateBottomAccessory(status: status)
            .task {
                for _ in 0..<340 {
                    status.increment(id)
                    try? await Task.sleep(for: .milliseconds(10))
                }
            }
    }
}
