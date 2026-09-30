// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Presents the latest major-feature announcement.
struct ChangelogView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundStyle(.teal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.Changelog.titleImportTitle)
                            .font(.title2.bold())
                        Text(Strings.Changelog.titleImportDescription)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    ConfirmButton()
                }
            }
            .navigationTitle(Strings.Changelog.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ChangelogView()
                .presentationDetents([.height(320), .large])
                .presentationDragIndicator(.visible)
        }
}
