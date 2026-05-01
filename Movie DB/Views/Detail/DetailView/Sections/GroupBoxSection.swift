// Copyright © 2019 Jonas Frey. All rights reserved.

import os.log
import SwiftUI

struct GroupBoxSection<Content: View>: View {
    @EnvironmentObject private var mediaObject: Media

    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding(.top, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                Text(title)
            }
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            BasicInfoSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            BasicInfoSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}
