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
                    Text(Strings.Detail.metadataSectionHeader)
                }
            ) {
                if let id = mediaObject.id {
                    Text(id.uuidString)
                        .headline(Text(Strings.Detail.internalIDHeadline))
                }
                Text(mediaObject.creationDate.formatted(date: .abbreviated, time: .shortened))
                    .headline(Text(Strings.Detail.createdHeadline))
                if let modificationDate = mediaObject.modificationDate {
                    Text(modificationDate.formatted(date: .abbreviated, time: .shortened))
                        .headline(Text(Strings.Detail.lastModifiedHeadline))
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
