//
//  TrailersView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TrailersView: View {
    @EnvironmentObject private var mediaObject: Media
    
    var trailers: [Video] {
        mediaObject
            .videos
            .filter { $0.type == "Trailer" }
            // Only use trailers we can build a valid URL for
            .filter { $0.videoURL != nil }
    }
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(header: header) {
                Group {
                    if trailers.isEmpty {
                        // No providers available
                        HStack {
                            Spacer()
                            Text(Strings.Detail.trailersNoneAvailable)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(trailers, id: \.key) { video in
                                    TrailerView()
                                        .environmentObject(video)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(maxHeight: 400)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 3)
                    }
                }
            }
        }
    }
    
    @ViewBuilder var header: some View {
        HStack {
            Image(systemName: "play.rectangle")
            Text(Strings.Detail.trailersSectionHeader)
        }
    }
}

#Preview {
    List {
        TrailersView()
            .previewEnvironment()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
    }
}
