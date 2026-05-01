// Copyright © 2026 Jonas Frey. All rights reserved.

import OSLog
import SwiftUI

struct UserDataPreviewSection: View {
    @EnvironmentObject private var mediaObject: Media

    private var watchAgainTitle: String {
        mediaObject.type == .show ? Strings.Detail.watchAgainHeadlineShow : Strings.Detail.watchAgainHeadline
    }

    var body: some View {
        GroupBoxSection(title: Strings.Detail.userDataSectionHeader) {
            SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                .headline("arrow.clockwise", watchAgainTitle)

            WatchDateView()
                .headline("calendar", Strings.Detail.watchDateHeadline)

            TagListView.TagListViewLabel(tags: mediaObject.tags)
                .headline("tag.fill", Strings.Detail.tagsHeadline)

            TruncatingTextSheet(
                mediaObject.notes.isEmpty ? "—" : mediaObject.notes,
                sheetTitle: Strings.Detail.notesHeadline,
                lineLimit: 3
            )
            .headline("note.text", Strings.Detail.notesHeadline)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataPreviewSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataPreviewSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}
