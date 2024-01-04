//
//  TrailerView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TrailerView: View {
    @EnvironmentObject private var trailer: Video
    
    var body: some View {
        if let videoURL = trailer.videoURL {
            Link(destination: videoURL) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.calloutBackground)
                    VStack(spacing: 16) {
                        Text(trailer.name)
                            .lineLimit(2, reservesSpace: false)
                            .frame(width: 140)
                            .padding(0)
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                            .padding(4)
                    }
                }
            }
        } else {
            EmptyView()
                .onAppear {
                    // We should never arrive here. Videos with missing URLs are filtered out in the super view
                    assertionFailure("Trying to present a trailer with an invalid URL.")
                }
        }
    }
}

#Preview {
    TrailerView()
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie.videos.first(where: \.type, equals: "Trailer")!)
}
