// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct UserDataSection: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing

    var body: some View {
        if isEditing {
            UserDataEditingSection()
        } else {
            UserDataPreviewSection()
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Movie Editing") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
    .environment(\.isEditing, true)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}

#Preview("Show Editing") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
    .environment(\.isEditing, true)
}
