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
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(
                header: HStack {
                    Image(systemName: "paperclip")
                    Text(
                        "detail.metadata.header",
                        comment: "The section header for the metadata section in the detail view"
                    )
                }
            ) {
                if let id = mediaObject.id {
                    Text(id.uuidString)
                        .headline(
                            "detail.metadata.headline.internalID",
                            comment: "The headline for the 'internal id' property in the detail view"
                        )
                }
                Text(mediaObject.creationDate.formatted(date: .abbreviated, time: .shortened))
                    .headline(
                        "detail.metadata.headline.created",
                        comment: "The headline for the 'creation date' property in the detail view"
                    )
                if let modificationDate = mediaObject.modificationDate {
                    Text(modificationDate.formatted(date: .abbreviated, time: .shortened))
                        .headline(
                            "detail.metadata.headline.lastModified",
                            comment: "The headline for the 'last modified' property in the detail view"
                        )
                }
            }
        }
    }
}

struct MetadataInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MetadataInfo()
        }
            .environmentObject(PlaceholderData.movie as Media)
    }
}
