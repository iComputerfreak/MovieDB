//
//  CastInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CastInfo: View {
    @EnvironmentObject private var mediaObject: Media
    @State private var personThumbnails: [Int: UIImage?] = [:]
    
    @State private var cast: [CastMemberDummy] = []
    
    var body: some View {
        Group {
            if self.mediaObject.isFault {
                EmptyView()
            } else if cast.isEmpty {
                HStack {
                    ProgressView()
                    Text(Strings.Generic.loadingText)
                }
                .task(priority: .userInitiated) {
                    print("Loading cast for \(mediaObject.title)")
                    do {
                        self.cast = try await TMDBAPI.shared.cast(for: mediaObject.tmdbID, type: mediaObject.type)
                    } catch {
                        print(error)
                        AlertHandler.showError(
                            title: Strings.Detail.Alert.errorLoadingCastTitle,
                            error: error
                        )
                    }
                }
            } else {
                List {
                    ForEach(cast) { member in
                        HStack {
                            AsyncImage(
                                url: member.imagePath.map { imagePath in
                                    Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.castImageSize)
                                }) { image in
                                    image
                                        .thumbnail()
                                } placeholder: {
                                    Image(JFLiterals.posterPlaceholderName)
                                        .thumbnail()
                                }
                            Text(member.name)
                                .headline(verbatim: member.roleName)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(Strings.Detail.castLabel)
    }
}

struct CastInfo_Previews: PreviewProvider {
    static var previews: some View {
        CastInfo()
    }
}
