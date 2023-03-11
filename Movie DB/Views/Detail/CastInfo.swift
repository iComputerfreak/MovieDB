//
//  CastInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct CastInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    @State private var cast: [CastMemberDummy] = []
    
    var body: some View {
        Group {
            if self.mediaObject.isFault {
                EmptyView()
            } else if cast.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(Strings.Generic.loadingText)
                }
                .task(priority: .userInitiated) {
                    Logger.api.info("Loading cast for \(mediaObject.title, privacy: .public)")
                    do {
                        self.cast = try await TMDBAPI.shared.cast(for: mediaObject.tmdbID, type: mediaObject.type)
                    } catch {
                        Logger.api.error(
                            "Error loading cast for \(mediaObject.title, privacy: .public): \(error, privacy: .public)"
                        )
                        AlertHandler.showError(
                            title: Strings.Detail.Alert.errorLoadingCastTitle,
                            error: error
                        )
                    }
                }
            } else {
                List {
                    ForEach(cast) { member in
                        CastMemberRow(castMember: member)
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
            .environmentObject(PlaceholderData.movie as Media)
    }
}
