//
//  MetadataInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MetadataInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    var lists: [any MediaListProtocol] {
        (mediaObject.isFavorite ? [PredicateMediaList.favorites] : []) +
        (mediaObject.isOnWatchlist ? [PredicateMediaList.watchlist] : []) +
        // TODO: Does not update when a list changes
        // Maybe use a @FetchRequest for the user lists? (but mediaObject is not available at initialization)
        Array(mediaObject.userLists).sorted(on: \.name, by: <)
    }
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(
                header: HStack {
                    Image(systemName: "paperclip")
                    Text(Strings.Detail.metadataSectionHeader)
                }
            ) {
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
                .padding(.top, 5)
                .headline("Lists")
                if let id = mediaObject.id {
                    Text(id.uuidString)
                        .headline(Strings.Detail.internalIDHeadline)
                }
                Text(mediaObject.creationDate.formatted(date: .abbreviated, time: .shortened))
                    .headline(Strings.Detail.createdHeadline)
                if let modificationDate = mediaObject.modificationDate {
                    Text(modificationDate.formatted(date: .abbreviated, time: .shortened))
                        .headline(Strings.Detail.lastModifiedHeadline)
                }
            }
        }
    }
}

#Preview {
    List {
        MetadataInfo()
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}
