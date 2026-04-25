// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct MetadataInfoSection: View {
    @EnvironmentObject private var mediaObject: Media

    private var lists: [any MediaListProtocol] {
        (mediaObject.isFavorite ? [PredicateMediaList.favorites] : []) +
        (mediaObject.isOnWatchlist ? [PredicateMediaList.watchlist] : []) +
        // TODO: Does not update when a list changes
        // Maybe use a @FetchRequest for the user lists? (but mediaObject is not available at initialization)
        Array(mediaObject.userLists).sorted(on: \.name, by: <)
    }

    var body: some View {
        GroupBoxSection(title: Strings.Detail.metadataSectionHeader) {
            Group {
                if lists.isEmpty {
                    Text(Strings.Detail.noListsLabel)
                } else {
                    WrappingHStack {
                        ForEach(lists, id: \.hashValue) { list in
                            CapsuleLabelView {
                                (Text(Image(systemName: list.iconName)) + Text(" ") + Text(list.name))
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .headline(Image(systemName: "list.bullet"), "Lists")

            if let id = mediaObject.id {
                Text(id.uuidString)
                    .headline(Image(systemName: "number"), Strings.Detail.internalIDHeadline)
            }

            Text(mediaObject.creationDate.formatted(date: .abbreviated, time: .shortened))
                .headline(Image(systemName: "calendar.badge.plus"), Strings.Detail.createdHeadline)

            if let modificationDate = mediaObject.modificationDate {
                Text(modificationDate.formatted(date: .abbreviated, time: .shortened))
                    .headline(Image(systemName: "pencil"), Strings.Detail.lastModifiedHeadline)
            }

            if let lastUpdated = mediaObject.lastUpdated {
                Text(lastUpdated.formatted(date: .abbreviated, time: .shortened))
                    .headline(Image(systemName: "arrow.triangle.2.circlepath"), Strings.Detail.lastUpdatedHeadline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        VStack(alignment: .leading) {
            MetadataInfoSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}
